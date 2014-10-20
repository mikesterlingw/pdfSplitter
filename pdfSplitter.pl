#!/usr/bin/env perl
use strict; use warnings;
use PDF::API2;

sub splitPage {

    my $name = $_[0];

    if ($name =~ m/\.pdf$/) {
	print("\nReading ", $name, "\n");
  
	if(eval{ PDF::API2->open($name) }) {
	    
	    print "Opened\n";
	    
	    my $oldpdf = PDF::API2->open($name);
	    
	    my $newpdf = PDF::API2->new;
	    
	    for my $page_nb (2..$oldpdf->pages) {
		my ($page, @cropdata);
		
		$page = $newpdf->importpage($oldpdf, $page_nb);
		@cropdata = $page->get_mediabox;
		$cropdata[2] /= 2;
		$page->cropbox(@cropdata);
		$page->trimbox(@cropdata);
		$page->mediabox(@cropdata);
		
		$page = $newpdf->importpage($oldpdf, $page_nb);
		@cropdata = $page->get_mediabox;
		$cropdata[0] = $cropdata[2] / 2;
		$page->cropbox(@cropdata);
		$page->trimbox(@cropdata);
		$page->mediabox(@cropdata);
	    }
	
	    (my $newfilename = $name) =~ s/(.*)\.(\w+)$/$1.clean.$2/;
	    $newpdf->saveas($newfilename);
	    print("Success splitting", $newfilename, "\n");
	}
    } else {
	print $name, " not a PDF\n";
    }
}


my $fileArg = shift;

# Check if it's a directory
if($fileArg =~ m/\/$/) {

    my $dir = $fileArg;

    print("Reading from: ", $dir, '\n');

    opendir (DIR, $dir) or die $!;
    
    while (my $filename = readdir(DIR)) {
	splitPage($dir.$filename);
    }

    closedir(DIR);
} else {
    splitPage($fileArg);
}





__END__
