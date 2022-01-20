#line 1 "KSE/Functions/Main.pm"
package KSE::Functions::Main;

use Config::IniMan;

use Cwd;

use MyAppData;

use KSE::GUI::Appearance;
use KSE::GUI::Classes;
use KSE::GUI::Equipment;
use KSE::GUI::GameControls;
use KSE::GUI::Globals;
use KSE::GUI::Feats;
use KSE::GUI::Inventory;
use KSE::GUI::Journal;
use KSE::GUI::Main;
use KSE::GUI::NPC;
use KSE::GUI::Portrait;
use KSE::GUI::Powers;
use KSE::GUI::RadioOptionsControls;		#Gender, CheatUsed, Min1HP, CurrentParty
use KSE::GUI::SpinboxControls;			#TimePlayed, Attributes, HitPoints, ForcePoints, Skills
use KSE::GUI::Soundset;
use KSE::GUI::TextEntryControls;		#SaveGameName, Area, LastModule, FirstName

#use KSE::Functions::GameControls;
#use KSE::Functions::TextEntryControls;		#SaveGameNam, Area, LastModule, FirstName
#use KSE::Functions::RadioOptionsControls;	#Gender, CheatUsed, Min1HP, CurrentParty
#use KSE::Functions::SpinButtonControls;	#TimePlayed, Attributes, HitPoints, ForcePoints
use KSE::Functions::Appearance;
use KSE::Functions::Classes;
use KSE::Functions::Directory;
use KSE::Functions::Equipment;
use KSE::Functions::Feats;
use KSE::Functions::Globals;
use KSE::Functions::Inventory;
use KSE::Functions::Journal;
use KSE::Functions::NPC;
use KSE::Functions::Portrait;
use KSE::Functions::Powers;
use KSE::Functions::Saves;
use KSE::Functions::Soundset;

use Math::Trig;

my $base = getcwd;
my $language = "English";

$pi     = 3.1415926535897932384626433832795;
$rad    = 0.017453292519943295769236907684939;
$cos    = 0.00045686813729550915076811877091485;
$negcos = -0.00045686813729550915076811877091485;
$number = 90 * ($pi/180);

sub GetBaseDir
{
	return $base;
}

sub GetLanguage
{
	return $language;
}

sub SetLanguage
{
	$language = shift;
}

sub GetLanguageID
{
       if($language eq 'English')				{ return 0;		}
	elsif($language eq 'French')				{ return 2;		}
	elsif($language eq 'German')				{ return 4;		}
	elsif($language eq 'Italian')				{ return 6;		}
	elsif($language eq 'Spanish')				{ return 8;		}
	elsif($language eq 'Polish')				{ return 10;	}
	elsif($language eq 'Korean')				{ return 256;	}
	elsif($language eq 'Simplified Chinese')	{ return 258;	}
	elsif($language eq 'Traditional Chinese')	{ return 260;	}
	elsif($language eq 'Japanese')				{ return 262;	}
	else										{ return 0;		}
}

sub GetLanguageName
{
       if($language == 0)	{ return 'English';				}
	elsif($language == 2)	{ return 'French';				}
	elsif($language == 4)	{ return 'German';				}
	elsif($language == 6)	{ return 'Italian';				}
	elsif($language == 8)	{ return 'Spanish';				}
	elsif($language == 10)	{ return 'Polish';				}
	elsif($language == 256)	{ return 'Korean';				}
	elsif($language == 258)	{ return 'Simplified Chinese';	}
	elsif($language == 260)	{ return 'Traditional Chinese';	}
	elsif($language == 262)	{ return 'Japanese';			}
	else					{ return 'English';				}
}

sub LoadPathINI
{
	my $ini = Config::IniMan->new("$base/kse_config.ini");
	
	$language = $ini->get('Language');
	$language = GetLanguageID($language);
	
	my $saves_shown = $ini->get('Saves_Shown');
	if(defined($saves_shown) == 0) { $saves_shown = 1; }
	KSE::GUI::Main::Set_Saves_Shown($saves_shown);
	
	my $saves_names = $ini->get('Saves_use_name');
	if(defined($saves_names) == 0) { $saves_names = 1; }
	KSE::Functions::Saves::Set_Saves_Name($saves_names);
	
	my $count = $ini->get('Path_Count');
	if(defined($count) == 0) { $count = 0; }
	
	my $cpath = $ini->get('Current_Path');
	if(defined($cpath) == 0) { $cpath = 0; }
	
	for (my $i = 0; $i <= $count; $i++)
	{
		next if ($i == $count && $count > 0);
		
#		print "I $i\n";
		my $cloud	= $ini->get('Path' . $i, 'Use_Cloud', 0);
		my $path	= $ini->get('Path' . $i, 'Path', $base);
		my $game	= $ini->get('Path' . $i, 'Game_Mode', 1);
		my $name	= $ini->get('Path' . $i, 'Game_Name', "KotOR 1");
		
		KSE::Functions::Directory::AddPath($name, $game, $cloud, $path);
	}
	
	KSE::Functions::Directory::SetCurrentDirectory($cpath);
}

sub SavePathINI
{
	my $ini = Config::IniMan->new("$base/kse_config.ini");
	
	$language = GetLanguageName($language);
	$ini->set('Language', $language);
	
	my $saves_shown = KSE::GUI::Main::Get_Saves_Shown();
	$ini->set('Saves_Shown', $saves_shown);

	my $saves_names = KSE::Functions::Saves::Get_Saves_Name();
	$ini->set('Saves_use_name', $saves_names);
	
	my $count = KSE::Functions::Directory::GetPathCount();
	$ini->set('Path_Count', $count);
	
	$ini->set('Current_Path', KSE::Functions::Directory::GetCurrentDirectory());
	
	for (my $i = 0; $i <= $count; $i++)
	{
		next if ($i == $count && $count > 0);
		
		my $cloud	= KSE::Functions::Directory::GetPathCloud($i);
		my $path	= KSE::Functions::Directory::GetPathPath($i);
		my $game	= KSE::Functions::Directory::GetPathGame($i);
		my $name	= KSE::Functions::Directory::GetPathName($i);
		
		$ini->add_section('Path' . $i);
		$ini->set('Path' . $i, 'Use_Cloud', $cloud);
		$ini->set('Path' . $i, 'Path', $path);
		$ini->set('Path' . $i, 'Game_Mode', $game);		
		$ini->set('Path' . $i, 'Game_Name', $name);		
	}
	
	$ini->write("$base/kse_config.ini");
}

sub GetOrientationDegrees
{
	my ($x, $y) = @_;
	
	my $quat1;
	my $quat2;
	my $quat1_deg;
	my $quat2_deg;
	if($x >= 0)
	{
		if($y >= 0)
		{
			$quat1 = acos($x);
			$quat2 = asin($y);
			
			$quat1_deg = $quat1 / ($pi/180);
			$quat2_deg = $quat2 / ($pi/180);
		}
		else
		{
			$quat1 = asin($x);
			$quat2 = acos($y);
			
			$quat1_deg = $quat1 / ($pi/180);
			$quat2_deg = $quat2 / ($pi/180);
			
			$quat1_deg += 270;
			$quat2_deg += 270;
		}
	}
	else
	{
		$quat1 = asin($x);
		$quat2 = acos($y);
		
		$quat1_deg = $quat1 / ($pi/180);
		$quat2_deg = $quat2 / ($pi/180);
		
		$quat1_deg += 270;
		$quat2_deg += 270;
	}
	
	if($quat1_deg > 360) { $quat1_deg -= 360; }
	
	return $quat1_deg;
}

sub GetOrientationRadians
{
	my $degree = shift;
	
	my $radian = $degree * $rad;
#	print "Radian of $degree is $radian\n";
	my @values = ();
	push (@values, cos($radian));
	push (@values, sin($radian));
	
	return @values;
}

return 1;