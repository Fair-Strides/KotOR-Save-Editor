# This script adds an icon to KSE's executable

use Win32::Exe;

if (($#ARGV + 1) != 2) {
    print "\nUsage: icon.pl <EXE> <ICON>";
    exit
}

$exe = Win32::Exe->new($ARGV[0]);
$exe->set_single_group_icon($ARGV[1]);
$exe->write;
