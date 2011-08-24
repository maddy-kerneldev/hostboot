#!/usr/bin/perl
#  IBM_PROLOG_BEGIN_TAG
#  This is an automatically generated prolog.
#
#  $Source: src/usr/hwpf/fapi/fapiParseAttributeInfo.pl $
#
#  IBM CONFIDENTIAL
#
#  COPYRIGHT International Business Machines Corp. 2011
#
#  p1
#
#  Object Code Only (OCO) source materials
#  Licensed Internal Code Source Materials
#  IBM HostBoot Licensed Internal Code
#
#  The source code for this program is not published or other-
#  wise divested of its trade secrets, irrespective of what has
#  been deposited with the U.S. Copyright Office.
#
#  Origin: 30
#
#  IBM_PROLOG_END

#
# Purpose:  This perl script will parse HWP Attribute XML files
# and add attribute information to a file called fapiAttributeIds.H
#
# Author: CamVan Nguyen
# Last Updated: 06/23/2011
#
# Version: 1.0
#
# Change Log **********************************************************
#
#  Flag  Track#    Userid    Date      Description
#  ----  --------  --------  --------  -----------
#                  camvanng  06/03/11  Created
#                  mjjones   06/06/11  Minor updates for integration
#                  mjjones   06/10/11  Added "use strict;"
#                  mjjones   06/23/11  Parse more info
#                  mjjones   07/05/11  Take output dir as parameter
#
# End Change Log ******************************************************

#
# Usage:
# fapiParseAttributeInfo.pl <output dir> <filename1> <filename2> ...

use strict;

#------------------------------------------------------------------------------
# Print Command Line Help
#------------------------------------------------------------------------------
my $numArgs = $#ARGV + 1;
if ($numArgs < 2)
{
    print ("Usage: fapiParseAttributeInfo.pl <output dir> <filename1> <filename2> ...\n");
    print ("  This perl script will parse attribute XML files and add\n");
    print ("  attribute information to a file called fapiAttributeIds.H\n");
    exit(1);
}

#------------------------------------------------------------------------------
# Specify perl modules to use
#------------------------------------------------------------------------------
use XML::Simple;
my $xml = new XML::Simple (KeyAttr=>[]);

# Uncomment to enable debug output
#use Data::Dumper;

#------------------------------------------------------------------------------
# Open output file for writing
#------------------------------------------------------------------------------
my $outputFile = $ARGV[0];
$outputFile .= "/";
$outputFile .= "fapiAttributeIds.H";
open(OUTFILE, ">", $outputFile);

#------------------------------------------------------------------------------
# Print Start of file information
#------------------------------------------------------------------------------
print OUTFILE "// fapiAttributeIds.H\n";
print OUTFILE "// This file is generated by perl script fapiParseAttributeInfo.pl\n\n";
print OUTFILE "#ifndef FAPIATTRIBUTEIDS_H_\n";
print OUTFILE "#define FAPIATTRIBUTEIDS_H_\n\n";
print OUTFILE "namespace fapi\n";
print OUTFILE "{\n\n";

#------------------------------------------------------------------------------
# Print AttributeId enumeration start
#------------------------------------------------------------------------------
print OUTFILE "\/**\n";
print OUTFILE " * \@brief Enumeration of attribute IDs\n";
print OUTFILE " *\/\n";
print OUTFILE "enum AttributeId\n{\n";

#------------------------------------------------------------------------------
# For each XML file
#------------------------------------------------------------------------------
foreach my $argnum (1 .. $#ARGV)
{
    my $infile = $ARGV[$argnum];

    # read XML file
    my $attributes = $xml->XMLin($infile);

    # Uncomment to get debug output of all attributes
    #print "\nFile: ", $infile, "\n", Dumper($attributes), "\n";

    #--------------------------------------------------------------------------
    # For each Attribute
    #--------------------------------------------------------------------------
    foreach my $attr (@{$attributes->{attribute}})
    {
        #----------------------------------------------------------------------
        # Print the AttributeId
        #----------------------------------------------------------------------
        if (!$attr->{id})
        {
            print ("fapiParseAttributeInfo.pl ERROR. Att 'id' missing\n");
            exit(1);
        }

        print OUTFILE "    ", $attr->{id}, ",\n";
    };
}

#------------------------------------------------------------------------------
# Print AttributeId enumeration end
#------------------------------------------------------------------------------
print OUTFILE "};\n\n";

#------------------------------------------------------------------------------
# Print Attribute Information comment
#------------------------------------------------------------------------------
print OUTFILE "\/**\n";
print OUTFILE " * \@brief Attribute Information\n";
print OUTFILE " *\/\n";

#------------------------------------------------------------------------------
# For each XML file
#------------------------------------------------------------------------------
foreach my $argnum (1 .. $#ARGV)
{
    my $infile = $ARGV[$argnum];

    # read XML file
    my $attributes = $xml->XMLin($infile);

    #--------------------------------------------------------------------------
    # For each Attribute
    #--------------------------------------------------------------------------
    foreach my $attr (@{$attributes->{attribute}})
    {
        #----------------------------------------------------------------------
        # Print a comment with the attribute description
        #----------------------------------------------------------------------
        if ($attr->{description})
        {
            print OUTFILE "// ", $attr->{id}, ": ", $attr->{description}, "\n";
        }

        #----------------------------------------------------------------------
        # Figure out the attribute array dimensions (if arry)
        #----------------------------------------------------------------------
        my $arrayDimensions = "";
        if ($attr->{array})
        {
            # Figure out the array dimensions
            my @vals = split(' ', $attr->{array});

            foreach my $val (@vals)
            {
                $arrayDimensions .= "[";
                $arrayDimensions .= ${val};
                $arrayDimensions .= "]";
            }
        }

        #----------------------------------------------------------------------
        # Print the typedef for each attribute's value type
        #----------------------------------------------------------------------
        if (!$attr->{valueType})
        {
            print ("fapiParseAttributeInfo.pl ERROR. Att 'valueType' missing\n");
            exit(1);
        }

        print OUTFILE "typedef ";
        my $attrDefaultValType;

        if ($attr->{valueType} eq 'uint8')
        {
            $attrDefaultValType = "uint8_t";
            print OUTFILE "uint8_t ", $attr->{id}, "_Type", $arrayDimensions, ";\n";
        }
        elsif ($attr->{valueType} eq 'uint32')
        {
            $attrDefaultValType = "uint32_t";
            print OUTFILE "uint32_t ", $attr->{id}, "_Type", $arrayDimensions, ";\n";
        }
        elsif ($attr->{valueType} eq 'uint64')
        {
            $attrDefaultValType = "uint64_t";
            print OUTFILE "uint64_t ", $attr->{id}, "_Type", $arrayDimensions, ";\n";
        }
        elsif ($attr->{valueType} eq 'string')
        {
            $attrDefaultValType = "char *";
            print OUTFILE "char * ", $attr->{id}, "_Type;\n";
        }
        else
        {
            print ("fapiParseAttributeInfo.pl ERROR. valueType not recognized: ");
            print $attr->{valueType}, "\n";
            exit(1);
        }

        #----------------------------------------------------------------------
        # Print the value enumeration (if it is specified)
        #----------------------------------------------------------------------
        if ($attr->{enum})
        {
            print OUTFILE "enum ", $attr->{id}, "_Enum\n{\n";

            # Values must be separated by white space
            my @vals = split(' ', $attr->{enum});

            foreach my $val (@vals)
            {
                print OUTFILE "    ", $attr->{id}, "_", ${val}, ",\n";
            }

            print OUTFILE "};\n";
        }

        #----------------------------------------------------------------------
        # Print the default value information
        #----------------------------------------------------------------------
        print OUTFILE "const bool ", $attr->{id}, "_HASDEFAULTVAL = ";

        if ($attr->{defaultValue})
        {
            print OUTFILE "true;\n";

            if ($attr->{valueType} eq 'string')
            {
                print OUTFILE "const char * const ", $attr->{id};
                print OUTFILE "_DEFAULTVAL = \"", $attr->{defaultValue};
                print OUTFILE "\";\n";
            }
            elsif ($attr->{enum})
            {
                print OUTFILE "const ", $attrDefaultValType, " ", $attr->{id};
                print OUTFILE "_DEFAULTVAL = ", $attr->{id}, "_";
                print OUTFILE $attr->{defaultValue}, ";\n";
            }
            else
            {
                print OUTFILE "const ", $attrDefaultValType, " ", $attr->{id};
                print OUTFILE "_DEFAULTVAL = ", $attr->{defaultValue}, ";\n";
            }
        }
        else
        {
            print OUTFILE "false;\n";

            if ($attr->{valueType} eq 'string')
            {
                print OUTFILE "const char * const ", $attr->{id};
                print OUTFILE "_DEFAULTVAL = \"\";\n";
            }
            else
            {
                print OUTFILE "const ", $attrDefaultValType, " ", $attr->{id};
                print OUTFILE "_DEFAULTVAL = 0;\n";
            }
        }

        #----------------------------------------------------------------------
        # If the attribute is read-only then define the _SETMACRO to something
        # that will cause a compile failure
        #----------------------------------------------------------------------
        if (!$attr->{writeable})
        {
            print OUTFILE "#define ", $attr->{id};
            print OUTFILE "_SETMACRO ATTRIBUTE_NOT_WRITABLE\n";
        }

        #----------------------------------------------------------------------
        # Print newline between each attribute's information
        #----------------------------------------------------------------------
        print OUTFILE "\n";
    };
}

#------------------------------------------------------------------------------
# Print End of file information
#------------------------------------------------------------------------------
print OUTFILE "}\n\n";
print OUTFILE "#endif\n";

#------------------------------------------------------------------------------
# Close output file
#------------------------------------------------------------------------------
close(OUTFILE);
