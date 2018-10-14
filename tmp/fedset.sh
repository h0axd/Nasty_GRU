#!/usr/bin/perl
system ("clear");
print "\n";
if ( $< == 0 )
  {
	print "The fedset.sh script is being run with root privileges.\n\n";
  } 
  else
  {
	print "Your username is - " . (getpwuid($<))[0] . "\n\n";
	print "You must be logged in as root or use sudo to run this script.\n\n";
	print "Do you want to continue fedset.sh via sudo?  <y n>\n";
	chomp ($response = <>);
	if ($response ne "y")
	    {print "\n\n";
    	     print "Run of fedset.sh was aborted by request\n\n";
             exit;}
        print "\n\n";
	use Cwd qw(abs_path);
	my $restartpath = abs_path($0);
        system ("sudo $restartpath");
        exit;
  }
$parmkernelname   = "vmlinuz";
$parminitrdname   = "initramfs.img";
$parmlinuxname    = "fedora";
$dirtarget        = "/boot/";
$dirsource        = "/boot/";

#####################################################################

$vmlinuz_link     = $dirsource . $parmkernelname;
$initrd_link      = $dirsource . $parminitrdname; 

$vmlinuz_date     = 0;
$vmlinuz_filename = "";
$initrd_date      = 0; 
$initrd_filename  = "";

print "\n";
print "Running the  - " . $parmlinuxname . " -  link setup using source directory   " . $dirsource . ".\n";
print "                                    The target directory is  " . $dirtarget . ".\n";
print "\n";

opendir(IMD, $dirsource) || die("Cannot open directory");
@filearray = readdir(IMD);
@filearray = sort @filearray;
closedir(IMD);
$kernelfound = "no";
$initrdfound = "no";

foreach $filename (@filearray) {
   if (index($filename, 'rescue') != -1) {next}
   if (index($filename, 'dump')   != -1) {next}
   if (($filename eq ".") or ($filename eq "..") or ($filename eq $parmkernelname) or ($filename eq $parminitrdname)) {next}
    	$fullfile    = ($dirsource . $filename);
  	$datechanged = (stat($fullfile))[9];
  	use Time::localtime;
  	use File::stat;
  	$fullfile_printtime = ctime(stat($fullfile)->mtime);
  	$first9 = substr($filename, 0, 9);
  	$first7 = substr($filename, 0, 7);
  	$last4  = substr($filename, -4);
  	if ($first7 eq "vmlinuz") {
    	     $kernelfound = "yes";
    	     print "The modify date for $fullfile         is $fullfile_printtime\n\n";
    	     if ($datechanged > $vmlinuz_date) {
	          $vmlinuz_date      = $datechanged;
    		  $vmlinuz_filename  = $filename;
             }
        }
  
  	if (($first9 eq "initramfs") && ($last4 eq ".img")) {
    	     $initrdfound = "yes";
     	     print "The modify date for $fullfile   is $fullfile_printtime\n\n";
     	     if ($datechanged > $initrd_date) {
	          $initrd_date = $datechanged;
	          $initrd_filename  = $filename;
             }
        }
}

if (($kernelfound eq "no") || ($initrdfound eq "no"))
   {print "The Fedora Linux kernel files were not found in the /boot directory\n\n";
   print  "      fedset.sh was aborted\n\n";
   exit;
}

system ("rm   -f        " . $vmlinuz_link);
system ("rm   -f        " . $initrd_link);

$vmlinuz_target = $dirtarget . $vmlinuz_filename;
# print   $vmlinuz_target . "    " . $vmlinuz_link . "  Linker \n";
link $vmlinuz_target , $vmlinuz_link||die "vmlinuz link failed";
$initrd_target  = $dirtarget . $initrd_filename;
link $initrd_target , $initrd_link||die   "initrd link failed";

$vmlinuz_printtime = ctime(stat($dirsource . $vmlinuz_filename)->mtime);
$initrd_printtime  = ctime(stat($dirsource . $initrd_filename)->mtime);
print "\n";
print "\n";
print "\n";
print "The most recent kernel filename is  $vmlinuz_filename          It was modified  $vmlinuz_printtime\n";
print "\n";
print "The most recent initrd filename is  $initrd_filename    It was modified  $initrd_printtime\n";
print "\n";
print "\n";
print "   fedset.sh kernel link setup successfully completed\n";
print "\n";