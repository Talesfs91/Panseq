#!/usr/bin/env perl

package Modules::Setup::Settings;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Log::Log4perl;
use File::Which;
use File::Basename;

#object creation
sub new {
	my ($class) = shift;
	my $self = {};
	bless( $self, $class );
	$self->_initialize(@_);
	return $self;
}

sub _initialize{
	my($self)=shift;

    #logging
    $self->logger(Log::Log4perl->get_logger());    
    $self->logger->info("Logger initialized in Modules::Setup::Settings");  

    $self->_getSettingsFromConfigurationFile(@_);
    $self->_setDefaults();
}

sub blastWordSize{
    my $self = shift;
    $self->{'_blastWordSize'} = shift // return $self->{'_blastWordSize'};   
}
sub maxNumberResultsInMemory{
	my $self = shift;
	$self->{'_maxNumberResultsInMemory'} = shift // return $self->{'_maxNumberResultsInMemory'};
}

sub orderedGenomeNames{
	my $self = shift;
	$self->{'_orderedGenomeNames'} = shift // return $self->{'_orderedGenomeNames'};
}

sub contigNamesFromGenome{
	my $self = shift;
	$self->{'_contigNamesFromGenome'} = shift // return $self->{'_contigNamesFromGenome'};
}

sub _genomeNameFromContig{
	my $self=shift;
	$self->{'__contigNameGenome'} = shift // return $self->{'__contigNameGenome'};
}

sub addMissingQuery{
	my $self=shift;
	$self->{'_addMissingQuery'} = shift // return $self->{'_addMissingQuery'};	
}

sub frameshift{
	my $self=shift;
	$self->{'_frameshift'} = shift // return $self->{'_frameshift'};
}

sub logger{
	my $self=shift;
	$self->{'_logger'} = shift // return $self->{'_logger'};
}

sub queryFile{
	my $self=shift;
	$self->{'_queryFile'}=shift // return $self->{'_queryFile'};
}

sub numberOfLoci{
	my $self=shift;
	$self->{'_numberOfLoci'}=shift // return $self->{'_numberOfLoci'};
}

sub numberOfBlastHitsToKeep{
	my $self=shift;
	$self->{'_numberOfBlastHitsToKeep'} = shift // return $self->{'_numberOfBlastHitsToKeep'};	
}

sub blastDatabase{
	my $self=shift;
	$self->{'_blastDatabase'} = shift // return $self->{'_blastDatabase'};	
}

sub toAnnotate{
	my $self=shift;
	$self->{'_toAnnotate'}=shift // return $self->{'_toAnnotate'};
}

sub mummerNumberOfInstances{
	my $self=shift;
	$self->{'_mummerNumberOfInstances'}=shift // return $self->{'_mummerNumberOfInstances'};
}

sub queryDirectory {
	my $self = shift;
	$self->{'_queryDirectory'} = shift // return $self->{'_queryDirectory'};
}

sub referenceDirectory {
	my $self = shift;
	$self->{'_referenceDirectory'} = shift // return $self->{'_referenceDirectory'};
}

sub baseDirectory {
	my $self = shift;
	$self->{'_baseDirectory'} = shift // return $self->{'_baseDirectory'};
}

sub numberOfCores {
	my $self = shift;
	$self->{'_numberOfCores'} = shift // return $self->{'_numberOfCores'};
}

sub mummerDirectory {
	my $self = shift;
	$self->{'_mummerDirectory'} = shift // return $self->{'_mummerDirectory'};
}

sub cdhitDirectory{
	my $self = shift;
	$self->{'_cdhitDirectory'} = shift // return $self->{'_cdhitDirectory'}
}


sub _cdhitExecutable{
    my $self = shift;
    $self->{'__cdhitExecutable'} = shift // return $self->{'__cdhitExecutable'}
}

sub cdhit{
	my $self = shift;
	$self->{'_cdhit'} = shift // return $self->{'_cdhit'}
}

sub minimumNovelRegionSize {
	my $self = shift;
	$self->{'_minimumNovelRegionSize'} = shift // return $self->{'_minimumNovelRegionSize'};
}

sub createGraphic {
	my $self = shift;
	$self->{'_createGraphic'} = shift // return $self->{'_createGraphic'};
}

sub combinedQueryFile {
	my $self = shift;
	$self->{'_combinedQueryFile'} = shift // return $self->{'_combinedQueryFile'};
}

sub combinedReferenceFile{
	my $self=shift;
	$self->{'_combinedReferenceFile'}=shift // return $self->{'_combinedReferenceFile'};
}

sub queryNameObjectHash {
	my $self = shift;
	$self->{'_queryNameObjectHash'} = shift // return $self->{'_queryNameObjectHash'};
}

sub nucB {
	my $self = shift;
	$self->{'_PanseqShared_novel_nucB'} = shift // return $self->{'_PanseqShared_novel_nucB'};
}

sub nucC {
	my $self = shift;
	$self->{'_PanseqShared_novel_nucC'} = shift // return $self->{'_PanseqShared_novel_nucC'};
}

sub nucD {
	my $self = shift;
	$self->{'_PanseqShared_novel_nucD'} = shift // return $self->{'_PanseqShared_novel_nucD'};
}

sub nucG {
	my $self = shift;
	$self->{'_PanseqShared_novel_nucG'} = shift // return $self->{'_PanseqShared_novel_nucG'};
}

sub nucL {
	my $self = shift;
	$self->{'_PanseqShared_novel_nucL'} = shift // return $self->{'_PanseqShared_novel_nucL'};
}

sub validator {
	my $self = shift;
	$self->{'_panseqShared_validator'} = shift // return $self->{'_panseqShared_validator'};
}

sub blastDirectory{
	my $self=shift;
	$self->{'_CoreAccessory_blastDirectory'}=shift // return $self->{'_CoreAccessory_blastDirectory'};
}

sub mummerNumberOfSplitFiles{
	my $self=shift;
	$self->{'_mummerNumberOfSplitFiles'}=shift // return $self->{'_mummerNumberOfSplitFiles'};
}

sub mummerBpPerSplitFile{
	my $self=shift;
	$self->{'_mummerBpPerSplitFile'}=shift // return $self->{'_mummerBpPerSplitFile'};
}

sub novelRegionFinderMode{
	my $self=shift;
	$self->{'_novelRegionFinderMode'} = shift // return $self->{'_novelRegionFinderMode'};
}

sub runMode{
	my $self=shift;
	$self->{'_mode'}=shift // return $self->{'_mode'};
}

sub fragmentationSize{
	my $self=shift;
	$self->{'_fragmentationSize'}=shift // return $self->{'_fragmentationSize'};
}

sub percentIdentityCutoff{
	my $self=shift;
	$self->{'_percentIdentityCutoff'}=shift // return $self->{'_percentIdentityCutoff'};
}

sub coreGenomeThreshold{
	my $self=shift;
	$self->{'_coreGenomeThreshold'}=shift // return $self->{'_coreGenomeThreshold'};
}

sub muscleExecutable{
	my $self=shift;
	$self->{'_muscleExecutable'}=shift // return $self->{'_muscleExecutable'};
}

sub accessoryType{
	my $self=shift;
	$self->{'_accessoryType'}=shift // return $self->{'_accessoryType'};
}

sub nrDatabase{
	my $self=shift;
	$self->{'_nrDatabase'} = shift // return $self->{'_nrDatabase'};	
}

sub storeAlleles{
	my $self=shift;
	$self->{'_storeAlleles'} = shift // return $self->{'_storeAlleles'};	
}

sub nameOrId{
	my $self=shift;
	$self->{'_nameOrId'} = shift // return $self->{'_nameOrId'};	
}

sub allelesToKeep{
	my $self=shift;
	$self->{'_allelesToKeep'} = shift // return $self->{'_allelesToKeep'};	
}

sub overwrite{
	my $self=shift;
	$self->{'_overwrite'} = shift // return $self->{'_overwrite'};	
}

sub sha1{
    my $self=shift;
    $self->{'_sha1'} = shift // return $self->{'_sha1'};
}

#methods
sub _getSettingsFromConfigurationFile {
	my ($self) = shift;

	if (@_) {
		my $fileName = shift;
		my $inFile = IO::File->new( '<' . $fileName ) or die "\nCannot open $fileName\n $!";
		
		while ( my $line = $inFile->getline ) {
			next unless $line =~ m/\s+/;
			
			$line =~ s/\R//g;
			my @la = split(/\s+/,$line);
            if(defined $la[0] && defined $la[1]){
                $self->_setSettingValue($la[0],$la[1]);
            }
            else{
                $self->logger->debug("$line cannot be parsed");
            }
		}
		$inFile->close();
	}
	else {
		$self->logger->fatal("No configuration file specified");
		#exit(1);
	}
}

=head2 _noValueSet

Sets an undefined value to 0.

=cut

sub _noValueSet{
	my $self=shift;
	my $name=shift;
	
	$self->logger->info("$name has an undefined value, setting to 0");
	return 0;
}



sub _setSettingValue{
	my $self = shift;
	my $setting=shift;
	my $value=shift;

	#we check to see if a setting set in the config file exists
	#if it does, we add the value
	#if not, we print a warning

	if($self->can($setting)){
		
		#ensure any directory has a trailing slash
		if($setting =~ m/Directory/){
			$value = $self->_trailingSlash($value);
		}
		$self->$setting($value);

		print("Loading setting $setting with value $value\n");
	}
	else{
		$self->logger->info("Setting $setting is not valid, skipping");
	}
}



=head2

Ensure that all Directory settings end in a slash, whether they are set by
the user or not.

=cut

sub _trailingSlash{
	my $self = shift;
	my $directory = shift;
	
	$directory =~ s/\/$//;
	$directory .= '/';
	
	return $directory;
}

sub _setDefaults{
	my $self=shift;

    unless(defined $self->blastDirectory){
        my $exe = which 'blastn';
        if(defined $exe){
            my @parts = fileparse($exe);
            $self->blastDirectory($parts[1]);
        }
    }

    unless(defined $self->mummerDirectory){
        my $exe = which 'nucmer';
        if(defined $exe){
            my @parts = fileparse($exe);
            $self->mummerDirectory($parts[1]);
        }
    }

    unless(defined $self->muscleExecutable){
        my $exe = which 'muscle';
        if(defined $exe){
            $self->muscleExecutable($exe);
        }
    }

    unless(defined $self->cdhitDirectory){
        my $exe = which 'cd-hit-est';
        if(defined $exe){
            my @parts = fileparse($exe);
            $self->cdhitDirectory($parts[1]);
        }
    }

	unless(defined $self->minimumNovelRegionSize){
		$self->minimumNovelRegionSize(0);
		$self->logger->info("Setting default minimumNovelRegionSize to 0");
	}

	unless(defined $self->fragmentationSize){
		$self->fragmentationSize(0);
		$self->logger->info("Setting default fragmentation size to 0");
	}

	unless(defined $self->runMode && $self->runMode eq 'pan' && defined $self->accessoryType){
		$self->accessoryType('binary');
	}
	
	unless(defined $self->storeAlleles){
		$self->storeAlleles(0);
	}
	
	unless(defined $self->nameOrId){
		$self->nameOrId('id');
	}
	
	unless(defined $self->coreGenomeThreshold){
		$self->coreGenomeThreshold(3);
	}
	
	unless(defined $self->addMissingQuery){
		$self->addMissingQuery(0);
	}
	
	unless(defined $self->allelesToKeep){
		$self->allelesToKeep(1);
	}
	
	unless(defined $self->overwrite){
		$self->overwrite(0);
	}

	unless(defined $self->frameshift){
		$self->frameshift(0);
	}

	unless(defined $self->maxNumberResultsInMemory){
		$self->maxNumberResultsInMemory(500);
	}

	unless(defined $self->blastWordSize){
		$self->blastWordSize(20);
	}

	unless(defined $self->novelRegionFinderMode) {
			$self->novelRegionFinderMode('no_duplicates');
	}

	unless(defined $self->nucB){
			$self->nucB(200);
	}

	unless(defined $self->nucC){
			$self->nucC(65);
	}

	unless(defined $self->nucD){
			$self->nucD(0.12);
	}

	unless(defined $self->nucG){
			$self->nucG(90);
	}

	unless(defined $self->nucL){
			$self->nucL(20);
	}

    unless(defined $self->numberOfCores){
        $self->numberOfCores(1);
    }

    unless(defined $self->percentIdentityCutoff){
        $self->percentIdentityCutoff(85);
    }

    unless(defined $self->sha1){
        $self->sha1(0);
    }
}


sub getGenomeNameFromContig{
	my $self=shift;
	my $inputName=shift // die "getGenomeNameFromContig requires input!";

	$inputName =~ s/_\(\d+\.\.\d+.+//;

	my $returnValue = $self->_genomeNameFromContig->{$inputName} // $inputName;
	return $returnValue;
}

1;

