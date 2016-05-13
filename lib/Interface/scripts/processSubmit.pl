#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use CGI;
use Data::Dumper;
use File::Path qw/make_path/;
use File::Copy;
use Net::FTP;
use Archive::Extract;
use Carp;

my $cgi = CGI->new();
my $serverSettings = _loadServerSettings();
my $NCBI_PREFIX = '/genomes/all/';

my $pid = fork();
if(!defined $pid){
    die "cannot fork process!\n $!";
};

if($pid){

    my $resultsUrl = '/page/output/' . $serverSettings->{'resultsHtml'};

my $hereDoc = <<END_HTML;
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>Panseq</title>
    <link href="/page/../css/panseq.css" rel="stylesheet">
    <link href="/page/../images/favicon.ico" rel="shortcut icon">
</head>
<body>
<div id="panseqImage">
    <p>Pan~genomic sequence analysis</p>
</div>


<div id="nav">
    <ul>
        <li><a href="/page/index.html">Home</a></li>
        <li><a href="/page/novel.html">Novel Regions</a></li>
        <li><a href="/page/pan.html">Pan-genome</a></li>
        <li><a href="/page/loci.html">Loci</a></li>
        <li><a href="/page/faq.html">FAQ</a></li>
    </ul>
</div>

<p>
    Your job has been submitted.
    Results, when available can be retrieved from:

    <a href="$resultsUrl">$resultsUrl</a>

    Please bookmark this address and return in a few minutes to retrieve your results.
</p>
</body>
</html>



END_HTML

    print $cgi->header() . $hereDoc;
}
else{
    print STDERR "processing the submission\n";

    #We need to close STDERR / STDOUT, otherwise Apache will wait for the
    #analyses to complete before showing the in-progress page.
    close STDERR;
    close STDOUT;

    #we need to determine what run mode (pan, novel, loci)
    my $runMode = $cgi->param('runMode');


    if($runMode eq 'novel'){
        foreach my $k(keys %{$cgi->{'param'}}){
            print STDERR "$k\n";
        }


        #for a novel run we need both query / reference directories
        my $newDir = $serverSettings->{'outputDirectory'} . $serverSettings->{'newDir'};
        my $queryDir = $newDir . 'query/';
        my $refDir = $newDir . 'reference/';
        my $resultsDir = $newDir . 'results/';

        unless(_createDirectory($newDir) == 1){
            _makeErrorPage();
        }

        unless(_createDirectory($queryDir) == 1){
            _makeErrorPage();
        }

        unless(_createDirectory($refDir) == 1){
            _makeErrorPage();
        }

        #create a hash of settings
        #base directory is used in the Panseq program to mean results dir
        #in this hash the results dir is one level down from the base dir
        #baseDirectory in Panseq really should have been called results,
        #but it is too late for that change now

        my %runSettings = (
            queryDirectory => $queryDir,
            referenceDirectory => $refDir,
            mummerDirectory => $serverSettings->{'mummerDirectory'},
            blastDirectory => $serverSettings->{'blastDirectory'},
            numberOfCores => $serverSettings->{'numberOfCores'},
            baseDirectory => $resultsDir,
            numberOfCores => $serverSettings->{'numberOfCores'},
            muscleExecutable => $serverSettings->{'muscleExecutable'},
            outputDirectory => $newDir,
            runMode => 'novel',
            nucB => $cgi->param('nucB'),
            nucC => $cgi->param('nucC'),
            nucD => $cgi->param('nucD'),
            nucG => $cgi->param('nucG'),
            nucL => $cgi->param('nucL')
        );

        my $batchFile = _createBatchFile(\%runSettings);
        if($batchFile eq 0){
            _makeErrorPage();
        }
        else{
            unless(_downloadUserSelections(\%runSettings) == 1){
                _makeErrorPage();
            }
        }

        my @qFiles = $cgi->upload('userQueryFiles');
        unless(_uploadUserFiles(\@qFiles, $runSettings{'queryDirectory'}) == 1){
            _makeErrorPage();
        }

        my @rFiles = $cgi->upload('userReferenceFiles');
        unless(_uploadUserFiles(\@rFiles, $runSettings{'referenceDirectory'}) ==1){
            _makeErrorPage();
        }


        unless(_checkFiles([$queryDir, $refDir]) == 1){
            _makeErrorPage();
        }


        #check that panseq finished correctly
        unless(_runPanseq($batchFile) == 1){
            _makeErrorPage();
        }

        #everything went peachy, no errors, so link to the download page
        unless(_createDownloadPage() ==1){
            _makeErrorPage();
        }

    }
    elsif($runMode eq 'pan'){

    }
    elsif($runMode eq 'loci'){

    }
    else{
        print STDERR "Panseq unknown runmode\n";
        exit(1);
    }
}



sub _createDownloadPage{
    #check if zip file exists
    my $resultsFile = $serverSettings->{'outputDirectory'} . $serverSettings->{'newDir'} . 'results/panseq_results.zip';
    print STDERR "Creating new download page $resultsFile\n";
    if(-e $resultsFile){

        my $downloadHtml =   $serverSettings->{'outputDirectory'} . $serverSettings->{'newDir'} . 'download.html';
        my $symFile = $serverSettings->{panseqDirectory} . 'Interface/html/output/' . $serverSettings->{resultsHtml};
        my $outputResultsSym = '/page/output/' . $serverSettings->{resultsHtml} . '.zip';
        my $serverResultsSym = $serverSettings->{panseqDirectory} . 'Interface/html/output/' . $serverSettings->{resultsHtml} . '.zip';

my $hereDoc = <<END_HTML;
<!DOCTYPE html>
    <html lang="en" xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <title>Panseq</title>
    <link href="/page/../css/panseq.css" rel="stylesheet">
    <link href="/page/../images/favicon.ico" rel="shortcut icon">
</head>
<body>
<div id="panseqImage">
    <p>Pan~genomic sequence analysis</p>
</div>


<div id="nav">
    <ul>
        <li><a href="/page/index.html">Home</a></li>
        <li><a href="/page/novel.html">Novel Regions</a></li>
        <li><a href="/page/pan.html">Pan-genome</a></li>
        <li><a href="/page/loci.html">Loci</a></li>
        <li><a href="/page/faq.html">FAQ</a></li>
    </ul>
</div>

<p>
   Please click here:<a href="$outputResultsSym" download="panseq_results.zip"> Panseq Results </a>to download your results.
</p>
</body>
</html>

END_HTML

        open(my $outFH, '>', $downloadHtml) or die ("Could not create $downloadHtml" and return 0);
        $outFH->print($hereDoc);



        if(-e $symFile){
            unlink($symFile);
        }
        symlink($downloadHtml, $symFile);


       if(-e $serverResultsSym){
           unlink($serverResultsSym);

       }
        symlink($resultsFile, $serverResultsSym);
        return 1;
    }
    else{
        print STDERR "Could not find $resultsFile\n";
        return 0;
    }
}


sub _uploadUserFiles{
    my $filesRef = shift;
    my $outputDir = shift;

    #make sure there are files to upload
    unless(scalar(@{$filesRef}) > 0){
        return 1;
    }

    foreach my $f(@{$filesRef}){
        my $cleanedFile = $f;
        $cleanedFile =~ s/\W/_/g;

        my $inFH = $f->handle;
        open(my $outFH, '>', $outputDir . $cleanedFile) or die ("Cannot create cleaned file from user upload\n" and return 0);

        #upload file using 1024 byte buffer
        my $buffer;
        my $bytesread = $inFH->read( $buffer, 1024 );
        while ($bytesread) {
            $outFH->print($buffer);
            $bytesread = $inFH->read( $buffer, 1024 );
        }
        $outFH->close();
    }

    return 1;
}



sub _checkFiles{
    my $directoriesRef = shift;

    foreach my $dir(@{$directoriesRef}){
        #requires functional SLURM
        my $systemLine = 'srun perl ' . $serverSettings->{'panseqDirectory'} . 'Interface/scripts/single_file_check.pl ' . $dir;
        my $systemCode = system($systemLine);

        unless($systemCode == 0){
            return 0;
        }
    }

    return 1;
}

sub _makeErrorPage{
    my $tempHtml =  $serverSettings->{'panseqDirectory'} . 'Interface/html/'. 'error.html';
    my $symFile = $serverSettings->{panseqDirectory} . 'Interface/html/output/' . $serverSettings->{resultsHtml};

    if(-e $symFile){
        unlink($symFile);
    }
    symlink($tempHtml, $symFile);
}

sub _runPanseq{
    my $configFile = shift;

    #requires SLURM to be operational
    my $systemLine = 'srun perl ' . $serverSettings->{'panseqDirectory'} . 'panseq.pl ' . $configFile;
    my $systemExit = system($systemLine);

    if($systemExit == 0){
       return 1;
    }
    else{
        return 0;
    }
}



sub _downloadUserSelections{
    my $runSettings = shift;

    my @ncbiQueryGenomes;
    my @ncbiReferenceGenomes;
    foreach my $p(keys %{$cgi->{'param'}}){
        if($p =~ m/^q_(.+)/){
            push @ncbiQueryGenomes, $1;
        }
        elsif($p =~ m/^r_(.+)/){
            push @ncbiReferenceGenomes, $1;
        }
    }

    #if no selections, skip
    unless(scalar(@ncbiQueryGenomes) > 0 || scalar(@ncbiReferenceGenomes) > 0){
        return 1;
    }

    #sets up the parameters for ncbi ftp connection
    my $host = 'ftp.ncbi.nlm.nih.gov';
    #constructs the connection
    my $ftp = Net::FTP->new($host, Debug => 1,Passive => 1) or die ("Cannot connect to genbank: $@" and return 0);
    #log in as anonymous, use email as password
    $ftp->login("anonymous",'chadlaing@inoutbox.com') or die ("Cannot login " . $ftp->message and return 0);


    $ftp->binary();
    my @allDownloadedFiles;
    foreach my $q(@ncbiQueryGenomes){
        my $ncbiFile = $NCBI_PREFIX . $q . '/' . $q . '_genomic.fna.gz';
        my $localFile = $runSettings->{'queryDirectory'} . $q;

        push @allDownloadedFiles, $localFile;
        $ftp->get($ncbiFile, $localFile) or die ("Cannot get $q" . $ftp->message and return 0);
    }

    foreach my $r(@ncbiReferenceGenomes){
        my $ncbiFile = $NCBI_PREFIX . $r . '/' . $r . '_genomic.fna.gz';
        my $localFile = $runSettings->{'referenceDirectory'} . $r;

        push @allDownloadedFiles, $localFile;
        $ftp->get($ncbiFile, $localFile) or die ("Cannot get $r" . $ftp->message and return 0);
    }
    $ftp->ascii();


    #extract them all
    foreach my $f(@allDownloadedFiles){
        my $extracter = Archive::Extract->new('archive'=>$f, type=>'gz');
        $extracter->extract(to=>$f . '.fna') or die ("Could not extract $f\n" and return 0);
        unlink $f;
    }

    return 1;
}


sub _createBatchFile{
    my $paramRef = shift;

    my $batchFile = $paramRef->{'outputDirectory'} . 'panseq.batch';
    open(my $batchFH, '>', $batchFile) or die ("Could not create $batchFile\n$!" and return 0);

    foreach my $k(sort keys %{$paramRef}){
        $batchFH->print($k . "\t" . $paramRef->{$k} . "\n");
    }

    $batchFH->close();
    return $batchFile;
}



sub _loadServerSettings{
    my $symlinkFile = './server.conf';

    my %settings;
    open(my $inFH, '<', $symlinkFile) or die "$!\n";

    while(my $line = $inFH->getline){
        $line =~ s/\R//g;
        my @la = split(/\s+/, $line);

        $settings{$la[0]}=$la[1];
    }

    #create newDir for output

    $settings{'newDir'} =  _createBaseDirectoryName();

    my $newDir = $settings{'newDir'};
    $newDir =~ s/\/$//;
    $settings{'resultsHtml'} = $newDir . '.html';

    return \%settings;
}



sub _createBaseDirectoryName{
    #use random number as well as localtime to ensure no directory overlap
    my $randomNumber = int( rand(8999) ) + 1000;
    my $directory    = localtime . $randomNumber;
    $directory =~ s/[\W]//g;

    return $directory . '/';
}


sub _createDirectory{
    my $dirName = shift;

    if(defined $dirName){
        #we don't want any permission issues, so don't downgrade the directory permissions
        umask(0);
        #from File::Path
        make_path($dirName) or die ("Couldn't create fastaBase $dirName\n" and return 0);

        return 1;
    }
    else{
        return 0;
    }

}