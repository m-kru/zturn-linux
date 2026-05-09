#!/bin/env tclsh

#
# Configuration variables
#

set BUILD_DIR "build"

set BUILDROOT_VERSION "2025.02.9"

set LINUX_URL "org-3189299@github.com:Xilinx/linux-xlnx.git"
# Linux branch or tag name to be downloaded.
set LINUX_BRANCH "xilinx-v2025.2"

# Command domains
set domains {br git gw linux misc sd uboot}

#
# Namespace containing internal util procedures.
#
namespace eval do {
  # Executes a commnd with live stdout and stderr printing.
  proc exec {args} {
    set cmd [list {*}$args]

    set chan [open "|[join $cmd { } ] 2>@1" r]
    while {[gets $chan line] >= 0} {
      puts $line
    }
    close $chan
  }
}

#
# Help related procedures
#
namespace eval help {
  proc help {args} {
    if {[llength $args] > 0} {
      set domain [lindex $args 0]
      set args [lrange $args 1 end]
      if {$domain ni $::domains} {
        puts stderr "invalid command domain '$domain'"
        puts stderr "valid command domains are: $::domains"
        return 1
      }

      set cmd ""
      if {[llength args] > 0} {
        set cmd [lindex $args 0]
      }

      $domain\::help $cmd
      return
    }

    puts "Usage:"
    puts "  ./do <domain> <command> \[args\]\n"
    puts "Help:"
    puts "  ./do help \[domain\] \[command\]\n"
    puts "Domains and commands:"
    foreach domain $::domains {
      $domain\::help
    }
  }

  proc print {text {cmd ""}} {
    if {$cmd eq ""} {
      help::summary $text
    } else {
      help::cmd $text $cmd
    }
  }

  proc summary {text} {
    foreach line [split $text "\n"] {
      # Skip empty lines
      if {$line eq ""} continue
      # Skip command documentation lines
      if {[regexp {^ {3,}} $line]} continue

      puts $line
    }
  }

  proc cmd {text cmd} {
    set state "first line"
    foreach line [split $text "\n"] {
      switch $state {
        "first line" {
          set domain $line
          set state "cmd search"
        }
        "cmd search" {
          if {[string match "  $cmd*" $line]} {
            puts $domain
            puts $line
            set state "in cmd"
          }
        }
        "in cmd" {
          if {[regexp {^ {4,}} $line] || $line eq ""} {
            puts $line
          } else {
            return
          }
        }
      }
    }
    if {$state eq "cmd search"} {
      puts stderr "domain '$domain' has no command '$cmd'"
      exit 1
    }
  }

  proc new {text} {
    # This creates the command: help::print {your text} $cmd
    # $text is evaluated NOW. $cmd is kept as a variable reference for LATER.
    set body "help::print \"$text\" \$cmd"

    # Now we define the proc using that body
    uplevel 1 [list proc help {{cmd ""}} $body]
  }
}

#
# Buildroot commands
#
namespace eval br {
  help::new "br
  setup  Set up buildroot for rootfs compilation in the $::BUILD_DIR directory
    The command automatically links .config to the valid configuration.
    The command does not start any compilation implicitly.
    You must explicitly cd to the buildroot diretory and call make."

  proc build {} {

  }

  proc rm {} {
    #exec rm -rf $::BUILD_DIR/
  }

  proc setup {} {
    set brTar "buildroot-$::BUILDROOT_VERSION.tar.gz"
    set brDir "buildroot-$::BUILDROOT_VERSION"

    exec mkdir -p cache
    if {![file exists "cache/$brTar"]} {
      exec wget "https://buildroot.org/downloads/$brTar"
    }

    exec mkdir -p $::BUILD_DIR
    cd $::BUILD_DIR
    if {![file exists $brDir]} {
      exec tar -xvf ../cache/$brTar
    }

    cd $brDir
    exec sh -c {BR2_DEFCONFIG=../../config/buildroot.conf make defconfig}

    cd package
    exec ln -s -f ../../../fw/examples .

    exec echo "
menu \"Exmaples\"
	source \"../../fw/examples/Config.in\"
endmenu " >> Config.in
  }
}

#
# Git commands
#
namespace eval git {
    help::new "git
  rm-ignored  Remove only files ignored by git.
    Usage:
      ./do git rm-ignored \\\[args\\\]
    The args are simply forwarded to the 'git clean -fdX' command."

  proc rm-ignored {args} {
    exec -ignorestderr git clean -fdX {*}$args
  }
}

#
# Gateware commands
#
namespace eval gw {
  help::new "gw
  build  Build the gateware design.
  rm     Remove $::BUILD_DIR/gw directory."

  proc build {args} {
    do::exec hbs run zturn::top {*}$args
  }

  proc rm {} {
    exec rm -rf $::BUILD_DIR/gw
  }
}

#
# Linux commands
#
namespace eval linux {
  help::new "linux
  dtbo   Compile DTS overlay.
  dtso   Generate DTS overlay.
  make   Compile Linux kernel.
  setup  Set up Linux for compilation in the $::BUILD_DIR directory.
    The command does not start any compilation implicitly.
    You must explicitly cd to the linux diretory and call make."

  proc dtbo {} {
    exec dtc -@ -I dts -O dtb -o build/system.dtbo build/system.dtso
  }

  proc dtso {} {
    exec ./scripts/dts-gen.py build/afbd/reg.json > build/system.dtso
  }

  proc setup {} {
    cd build
    exec git clone --branch $::LINUX_BRANCH --depth 1 $::LINUX_URL
  }
}

#
# Miscellaneous commands
#
namespace eval misc {
  help::new "misc
  bootbin  Generate boot.bin file to the build directory."

  proc bootbin {} {
    exec bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
  }
}

#
# SD card commands
#
namespace eval sd {
  help::new "sd
  cp  Copy provided file to the provided SD card partition.
    The command automatically mounts and unmounts the partition using the pmount command.
    The args are passed as is to the cp command.
    The sd partition name is assumed to be the last argument."

  proc cp {args} {
    if {[llength $args] < 2} {
      puts stderr "expected at least 2 arguments, file path and sd partition name"
      exit 1
    }

    set part [lindex $args end]
    set args [lreplace $args end end]

    set partPath "/dev/$part"

    if {![file exists $partPath]} {
      puts "partition file '$partPath' does not exist"
      exit 1
    }

    exec pmount $partPath
    exec cp {*}$args /media/$part
    exec pumount $partPath
  }
}

#
# U-Boot commands
#
namespace eval uboot {
  help::new "uboot
  bootscr  Compile boot script for U-Boot."

  proc bootscr {} {
    exec mkdir -p build
    exec mkimage -A arm -T script -C none -n "'Start script'" -d fw/boot/boot.txt build/boot.scr
  }
}

#
# Script logic
#

if {$argc < 1} {
  help::help
  exit 1
}

set domain [lindex $argv 0]
set argv [lrange $argv 1 end]

if {$domain eq "help"} {
  help::help {*}$argv
  exit 0
}

if {[llength $argv] < 1} {
  puts stderr "missing command, check help"
  exit 1
}

set cmd [lindex $argv 0]
set argv [lrange $argv 1 end]

$domain\::$cmd {*}$argv
