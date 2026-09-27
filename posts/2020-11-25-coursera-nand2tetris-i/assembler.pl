#!/usr/bin/env perl
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2020, Juan Picca <jumapico@gmail.com>
#
# Assembler for "Hack assembly language" introduced in Nand2Tetris course.
#
# See: <https://www.nand2tetris.org/course>, Project 6: Assembler
#
# TODO: Rewrite regex to match instructions without `=` and `;`, removing these
# characters from tables.
#-------------------------------------------------------------------------------
use strict;
use warnings;

#===============================================================================
# check parameters and open files
#===============================================================================

if (($#ARGV + 1) != 1 or substr($ARGV[0], -4, 4) ne ".asm") {
    print "\nUsage: assembler file.asm\n";
    exit 1;
}

open(my $in, "<", $ARGV[0]) or die "Failed to open file '$ARGV[0]'";
open(my $out, ">", substr($ARGV[0], 0, -4) . ".hack");

#===============================================================================
# initialization
#===============================================================================

# load initial symbols
my %symbols = (
    "R0"  => "0",
    "R1"  => "1",
    "R2"  => "2",
    "R3"  => "3",
    "R4"  => "4",
    "R5"  => "5",
    "R6"  => "6",
    "R7"  => "7",
    "R8"  => "8",
    "R9"  => "9",
    "R10" => "10",
    "R11" => "11",
    "R12" => "12",
    "R13" => "13",
    "R14" => "14",
    "R15" => "15",
    "SCREEN" => "16384",
    "KBD"    => "24576",
    "SP"   => "0",
    "LCL"  => "1",
    "ARG"  => "2",
    "THIS" => "3",
    "THAT" => "4",
);

# load table conversions
my %table_dest = (
    ""    => "000",
    "M="   => "001",
    "D="   => "010",
    "MD="  => "011",
    "A="   => "100",
    "AM="  => "101",
    "AD="  => "110",
    "AMD=" => "111",
);
my %table_comp = (
    "0"   => "0101010",
    "1"   => "0111111",
    "-1"  => "0111010",
    "D"   => "0001100",
    "A"   => "0110000",
    "M"   => "1110000",
    "!D"  => "0001101",
    "!A"  => "0110001",
    "!M"  => "1110001",
    "-D"  => "0001111",
    "-A"  => "0110011",
    "-M"  => "1110011",
    "D+1" => "0011111",
    "A+1" => "0110111",
    "M+1" => "1110111",
    "D-1" => "0001110",
    "A-1" => "0110010",
    "M-1" => "1110010",
    "D+A" => "0000010",
    "D+M" => "1000010",
    "D-A" => "0010011",
    "D-M" => "1010011",
    "A-D" => "0000111",
    "M-D" => "1000111",
    "D&A" => "0000000",
    "D&M" => "1000000",
    "D|A" => "0010101",
    "D|M" => "1010101",
);
my %table_jump = (
    ""    => "000",
    ";JGT" => "001",
    ";JEQ" => "010",
    ";JGE" => "011",
    ";JLT" => "100",
    ";JNE" => "101",
    ";JLE" => "110",
    ";JMP" => "111",
);

#===============================================================================
# first pass
#===============================================================================

my $cnt = 0;

while (my $line = <$in>) {
    if ($line =~ /^\s*$/ || $line =~ /^\s*\/\//) {
        # whitespaces - do nothing
    } elsif ($line =~ m/^\s*\(([^)]*)\)\s*(?:\/\/.*)?$/) {
        # add label
        $symbols{$1} = $cnt;
    } else {
        # count instruction
        $cnt++;
    }
}

#===============================================================================
# second pass
#===============================================================================

seek $in, 0, 0;  # rewind file
# open($file, "<", $ARGV[0]) or die "Failed to open file";  # reopen file

# now cnt is used for assign new variables
$cnt = 16;

while (my $line = <$in>) {
    if ($line =~ /^\s*$/ || $line =~ /^\s*\/\//) {
        # whitespaces - do nothing
    } elsif ($line =~ m/^\s*\(([^)]*)\)\s*(?:\/\/.*)?$/) {
        # label - do nothing
    } elsif ($line =~ m/^\s*@(\S+)\s*(?:\/\/.*)?$/) {
        my $value = $1;
        if ($value !~ /^\d+$/) { # if not number
            if (exists $symbols{$1}) {
                $value = $symbols{$1};
            } else {
                $value = $cnt;
                $symbols{$1} = $value;
                $cnt++;
            }
        }
        printf $out "0%015b\n", $value;
    } elsif ($line =~ m/^\s*(|M=|D=|MD=|A=|AM=|AD=|AMD=)(|0|1|-1|D|A|M|!D|!A|!M|-D|-A|-M|D\+1|A\+1|M\+1|D-1|A-1|M-1|D\+A|D\+M|D-A|D-M|A-D|M-D|D&A|D&M|D\|A|D\|M)(|;JGT|;JEQ|;JGE|;JLT|;JNE|;JLE|;JMP)\s*(?:\/\/.*)?$/) {
        printf $out "111%s%s%s\n", $table_comp{$2}, $table_dest{$1}, $table_jump{$3};
    } else {
        die("Error with line: '$line'");
    }
}
