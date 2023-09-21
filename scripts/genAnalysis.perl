#!/usr/bin/perl

$number_args = $#ARGV + 1;  
if ($number_args != 1) {  
    print "Wrong entry. Please enter the name of a par file without extension .\n";  
    exit;  
}  
$parFile=$ARGV[0];  

$ENV{'PATH'} = "../bin:$ENV{'PATH'}";


$path = "../EIG/bin";

$command = $path;
$command .= "smartpca";
$command .= " -p $file >$file.log";
print("$command\n");
system("$command");

$command = "../bin/ploteig";
$command .= " -i $file.evec ";
$command .= " -c 1:2 ";
$command .= " -p Case:Control ";
$command .= " -x ";
$command .= " -o $file.plot.xtxt "; # must end in .xtxt
print("$command\n");
system("$command");

$command = "../EIG-8.0.0/bin/evec2pca.perl 2 $file.evec $file.ind $file.pca";
print("$command\n");
system("$command");
