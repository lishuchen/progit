#! /usr/bin/perl

###############################################################################
###############################################################################
#
# To add a table of contents, based on its headings, to an HTML page.
#
#			Version 2
#
#	by Andrew Hardwick, http://duramecho.com, 2002/3/22
#
#	Released under GNU Public Licence.
#
###############################################################################
###############################################################################
#
# How To Use
#
# Run from a command line with the source file name as arguement.
# If it finds an existing table of contents from this program then it will
#  replace it, otherwise it will add a new table at the top of the HTML body
#  (if you move this, be sure to move the '<!--TableOfContentsAnchor:...-->'
#  markers as well so that, if you need the table of contents updated, this
#  program can tell where you want the table of contents to be).
#
###############################################################################
#
# Known Deficiencies
#
# It ignores commenting out of HTML sections so it may find spurious headings.
# It does not check that the anchors it puts in and the HTML the comments it
#  puts in the HTML to mark the bits it has inserted don't duplicate existing
#  ones.
#
###############################################################################
###############################################################################

# Include libraries
use Cwd;		# To find current directory
use strict;		# Disenable automatic variables

# Global Variables
my @HeadingCount;
my @HeadingTexts;
my @HeadingLevels;
my @HeadingLabels;

###############################################################################
# Main rountine
###############################################################################

{	my ($c,$d);
	# Get data from file
	my $From=cwd().'/'.$ARGV[0];
	open(FILETOPROCESS,'<'.$From)||
			die("Cannot open $From to read.");
	my $Html;
	read FILETOPROCESS,$Html,-s $From;
	close FILETOPROCESS;
	# Remove any old anchors
	$Html=~s/<!--TableOfContentsAnchor:Begin-->
			.*?
			<!--TableOfContentsAnchor:End-->
			//gsx;
	# Find all headings & mark them with anchors
	$Html=~s/<H(\d)(.*?)>(.*?)<\/H\1>/
			'<H'.$1.$2.'><!--TableOfContentsAnchor:Begin--><A NAME="'.
			MarkHeading($3,$1).
			'"><\/A><!--TableOfContentsAnchor:End-->'.
			$3.'<\/H'.$1.'>'/gise;
	# Avoid jumping down more than one level at a time by adding null headings
	for($c=0;$c<scalar(@HeadingTexts)-1;$c++)
	{	if($HeadingLevels[$c]<$HeadingLevels[$c+1]-1)
		{	splice(@HeadingLevels,$c+1,0,$HeadingLevels[$c]+1);
			splice(@HeadingTexts,$c+1,0,'');
			splice(@HeadingLabels,$c+1,0,'');}}
	# Start HTML table of contents
	my $Toc="<!--TableOfContents:Begin-->\n<UL>\n";
	my $PreviousHeadingLevel=1;
	# Add in contents lines
	for($c=0;$c<scalar(@HeadingTexts);$c++)
	{	# Indent/outdent contents line
		for($d=$PreviousHeadingLevel;$d<$HeadingLevels[$c];$d++)
		{	$Toc=~s/^(.*)<\/LI>(.*?)$/$1<UL>$2/s;}
		for($d=$PreviousHeadingLevel;$d>$HeadingLevels[$c];$d--)
		{	$Toc.="<\/UL><\/LI>\n";}
		# Write a contents line
		$Toc.='<LI><A HREF="#'.$HeadingLabels[$c].'">'.
				$HeadingTexts[$c]."<\/A><\/LI>\n";
		$PreviousHeadingLevel=$HeadingLevels[$c];}
	# Outdent fully
	for($d=$PreviousHeadingLevel;$d>1;$d--)
		{	$Toc=~s/^(.*)<\/LI>(.*?)$/$1<\/UL>$2/s;}
	# Remove null links
	$Toc=~s/<A HREF=\"#\"><\/A>//g;
	# Finish off table of contents
	$Toc.="<\/UL>\n<!--TableOfContents:End-->\n";
	# Replace old table of contents with new, or put at top if no old one
	if(!($Html=~s/<!--TableOfContents:Begin-->.*?<!--TableOfContents:End-->/$Toc/sx))
	{	$Html=~s/(<BODY.*?>)/$1\n$Toc/is;}
	# Write data back to the file
	open(FILETOPROCESS,'>'.$From)||
			die("Cannot open $From to write.");
	print FILETOPROCESS $Html;
	close FILETOPROCESS;}

###############################################################################
# MarkHeading
###############################################################################
# This works out a heading number for a heading, adds the heading to a 
#  list and creates an anchor in the heading
###############################################################################
# Parameters
#  1: The text of the heading.
#  2: The level (1-9) of the heading.
# Returns
#  A label to use for the HTML anchor.
###############################################################################

sub MarkHeading
{	my ($HeadingText,$HeadingLevel)=@_;
	# Paranoia
	$HeadingLevel=1 if($HeadingLevel<1);
	$HeadingLevel=9 if($HeadingLevel>9);
	# Work out heading number (add at current level & trim after)
	$HeadingCount[$HeadingLevel-1]++;
	@HeadingCount[$HeadingLevel..8]=(0)x9;
	my $HeadingNumber=join('.',@HeadingCount[0..($HeadingLevel-1)]);
	# Create a label
	my $Label='Section_'.$HeadingNumber;
	# Remove any HTML tags from the heading text
	$HeadingText=~s/<.*?>//gis;
	# Store the results
	push(@HeadingTexts,"$HeadingNumber$HeadingText");
	push(@HeadingLevels,$HeadingLevel);
	push(@HeadingLabels,$Label);
	# Display progress on screen
	print '-'x$HeadingLevel." $HeadingText\n";
	return $Label;}

###############################################################################
