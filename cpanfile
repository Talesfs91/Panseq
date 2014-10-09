on configure =>sub{
    requires 'Parallel::ForkManager' > 0;
    requires 'Log::Log4perl' > 0;
    requires 'FindBin' > 0;
    requires 'IO::File' > 0;
    requires 'File::Copy' > 0;
    requires 'Role::Tiny' > 0;
    requires 'Bio::SeqIO' > 0;
    requires 'Bio::DB::Fasta' > 0;
    requires 'File::Temp' > 0;
    requires 'Bio::Seq' > 0;
    requires 'File::Basename' > 0;
    requires 'Tie::Log4perl' > 0;
    requires 'Archive::Zip' > 0;
    requires 'Test::Pretty' > 0;
    requires 'Getopt::Long' > 0;
    requires 'Digest::MD5' > 0;
}
