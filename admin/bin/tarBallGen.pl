#!/usr/bin/perl -w
use strict;

#################################
# PLEASE READ
# The following is a quick hack to generate the tarball 
# Until it is made more "sophisticated", please uncomment the following lines
# to appropriate values, comment the die message below and go ahead.

my $tag = undef;
my $rc = undef;
my $prefix = undef;
my $username = undef;


$tag       =           "UVM_1_1_a";
$rc        =           "RC4";
$prefix    =           "uvm-1.1a";
$username  =           "ambarsarkar";
my $debug  =           1; # Do everything except push if TRUE
die "Please set params above\n";

##################################

my $tar = "${prefix}_$rc.tar";

die "uvm already exists" if (-e "uvm");
die "$tar already exists" if -e $tar;

my $cmd = "git clone ssh://$username\@uvm.git.sourceforge.net/gitroot/uvm/uvm";
system ("echo $cmd"); system ("$cmd");

chdir "uvm" or die "Failed to cd to uvm\n";

my $commit_id = `git describe`; chomp $commit_id;

# Tag the release
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $tag $commit_id;";
$cmd .= "git push --tags;";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Now generate the docs in a separate branch

# Create the branch
$cmd = "git checkout -b $tag\_".$rc."_WITHHTMLDOC $tag";
system ("echo $cmd"); system ("$cmd");

$ENV{ND} = "$ENV{'PWD'}/uvm/natural_docs";
chdir  "uvm_ref/nd" or die "Failed to cd to uvm_ref/nd";

$cmd .= "./gen_nd;";
system ("echo $cmd"); system ("$cmd");

chdir "../../distrib/docs" or die "Failed to cd to ../../distrib/docs";

$cmd = "git add html;  git commit -m \"commited docs for $tag\"";
system ("echo $cmd"); system ("$cmd");

chdir ".." or die "Failed to cd to .. (distrib)";

$cmd = "cp ../uvm_ref/relnotes/Mantis_3770.txt .";
system ("echo $cmd"); system ("$cmd");

$cmd = "git add Mantis_3770.txt;  git commit -m \"Added Mantis 3770 release note to distribution\"";
system ("echo $cmd"); system ("$cmd");

$cmd = "git push origin $tag\_".$rc."_WITHHTMLDOC";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Tag the release with doc
$commit_id = `git describe`; chomp $commit_id;
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $tag\_".$rc."_WITHHTMLDOC $commit_id;";
$cmd .= "git push --tags;";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Generate the tarball
$cmd = "git archive --prefix=$prefix/  $commit_id > ../../$tar";
system ("echo $cmd"); system ("$cmd");

print "Tarball ready: $tar\n";

