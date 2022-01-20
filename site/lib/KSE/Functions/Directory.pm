#line 1 "KSE/Functions/Directory.pm"
package KSE::Functions::Directory;

use Bioware::BIF;
use Bioware::GFF;
use Bioware::TPC;

use MyAppData;
use KSE::GUI::Main;

my %Directory;
$Directory{'Count'} = -1;
my $CurrentDirectory = undef;

my $AppData		= MyAppData::new();

sub SetCurrentDirectory
{
	$CurrentDirectory = shift;
}

sub GetCurrentDirectory
{
	return $CurrentDirectory;
}

sub GetCurrentGamePath
{
	return $Directory{$CurrentDirectory}{'Path'};
}

sub GetPathCloud
{
	my $index = shift;
	
	return $Directory{$index}{'Cloud'};
}

sub GetPathCount
{
	return $Directory{'Count'};
}

sub GetPathName
{
	my $index = shift;
	
	return $Directory{$index}{'Name'};
}

sub GetPathGame
{
	my $index = shift;
	
	return $Directory{$index}{'Game'};
}

sub GetPathPath
{
	my $index = shift;
	
	return $Directory{$index}{'Path'};
}

sub AddPath
{
	my ($name, $game, $cloud, $path) = @_;
	
	if($Directory{'Count'} == -1) { $Directory{'Count'} = 0; }
	
	$Directory{$Directory{'Count'}}{'Name'}		= $name;
	$Directory{$Directory{'Count'}}{'Game'}		= $game;
	$Directory{$Directory{'Count'}}{'Cloud'}	= $cloud;
	$Directory{$Directory{'Count'}}{'Path'}		= $path;
	
	$Directory{'Count'} += 1;
	
	return ($Directory{'Count'} - 1);
}

sub EditPath
{
	my ($index, $name, $game, $cloud, $path) = @_;
	
	$Directory{$index}{'Name'} = $name;
	$Directory{$index}{'Game'} = $game;
	$Directory{$index}{'Cloud'} = $cloud;
	$Directory{$index}{'Path'} = $path;
}

sub RemovePath
{
	my $index = shift;
	
	foreach my $entry ($index .. $Directory{'Count'} - 1)
	{
		$Directory{$entry}{'Name'} = $Directory{'Paths'}{$entry + 1}{'Name'};
		$Directory{$entry}{'Game'} = $Directory{'Paths'}{$entry + 1}{'Game'};
		$Directory{$entry}{'Path'} = $Directory{'Paths'}{$entry + 1}{'Path'};
	}
	
	delete $Directory{$Directory{'Count'}};
	
	$Directory{'Count'} -= 1;
}

sub MoveUp
{
	my $index = shift;
	
	if($index == GetCurrentDirectory()) { SetCurrentDirectory(GetCurrentDirectory() - 1); KSE::GUI::Main::SetPathOpen(GetCurrentDirectory()); }
	
	$Directory{'Fake'}{'Name'} = $Directory{$index - 1}{'Name'};
	$Directory{'Fake'}{'Game'} = $Directory{$index - 1}{'Game'};
	$Directory{'Fake'}{'Cloud'} = $Directory{$index - 1}{'Cloud'};
	$Directory{'Fake'}{'Path'} = $Directory{$index - 1}{'Path'};
	
	$Directory{$index - 1}{'Name'} = $Directory{$index}{'Name'};
	$Directory{$index - 1}{'Game'} = $Directory{$index}{'Game'};
	$Directory{$index - 1}{'Cloud'} = $Directory{$index}{'Cloud'};
	$Directory{$index - 1}{'Path'} = $Directory{$index}{'Path'};
	
	$Directory{$index}{'Name'} = $Directory{'Fake'}{'Name'};
	$Directory{$index}{'Game'} = $Directory{'Fake'}{'Game'};
	$Directory{$index}{'Cloud'} = $Directory{'Fake'}{'Cloud'};
	$Directory{$index}{'Path'} = $Directory{'Fake'}{'Path'};
	
	$Directory{'Fake'}{'Name'} = undef;
	$Directory{'Fake'}{'Game'} = undef;
	$Directory{'Fake'}{'Cloud'} = undef;
	$Directory{'Fake'}{'Path'} = undef;
}

sub MoveDown
{
	my $index = shift;
	
	if($index == GetCurrentDirectory()) { SetCurrentDirectory(GetCurrentDirectory() + 1); KSE::GUI::Main::SetPathOpen(GetCurrentDirectory()); }
	
	$Directory{'Fake'}{'Name'} = $Directory{$index + 1}{'Name'};
	$Directory{'Fake'}{'Game'} = $Directory{$index + 1}{'Game'};
	$Directory{'Fake'}{'Cloud'} = $Directory{$index + 1}{'Game'};
	$Directory{'Fake'}{'Path'} = $Directory{$index + 1}{'Path'};
	
	$Directory{$index + 1}{'Name'} = $Directory{$index}{'Name'};
	$Directory{$index + 1}{'Game'} = $Directory{$index}{'Game'};
	$Directory{$index + 1}{'Cloud'} = $Directory{$index}{'Game'};
	$Directory{$index + 1}{'Path'} = $Directory{$index}{'Path'};
	
	$Directory{$index}{'Name'} = $Directory{'Fake'}{'Name'};
	$Directory{$index}{'Game'} = $Directory{'Fake'}{'Game'};
	$Directory{$index}{'Cloud'} = $Directory{'Fake'}{'Game'};
	$Directory{$index}{'Path'} = $Directory{'Fake'}{'Path'};
	
	$Directory{'Fake'}{'Name'} = undef;
	$Directory{'Fake'}{'Game'} = undef;
	$Directory{'Fake'}{'Cloud'} = undef;
	$Directory{'Fake'}{'Path'} = undef;
}

sub GetFile
{
	my ($file_to_get, $BIF_to_look) = @_;
	if(defined($BIF_to_look) == 0) { $BIF_to_look = "data\\2da.bif"; }
	
	my $path = $Directory{$CurrentDirectory}{'Path'};
	
#	print "File: $file_to_get:";
	
	if(-e "$path/override" && $Directory{$CurrentDirectory}{'Game'} == 2)
	{
		opendir OVERDIR, "$path/override";
		my @folders = grep { !(/\\\.+$/) && -d } map {"$path/override/$_"} readdir(OVERDIR);
		closedir OVERDIR;
		
		foreach my $folder (@folders)
		{
			if(-e "$path/override/$folder/$file_to_get")
			{
#				print "$path/override/$folder/$file_to_get.\n";
				return "$path/override/$folder/$file_to_get";
			}
		}
	}
	
	if(-e "$path/override/$file_to_get")
	{
#		print "$path/override/$file_to_get.\n";
		return "$path/override/$file_to_get";
	}
	else
	{
		my $BIF_obj = Bioware::BIF->new($path);
		$BIF_obj->extract_resource($BIF_to_look, $file_to_get, KSE::Functions::Main::GetBaseDir() . '/temp/' . $file_to_get);

#		print KSE::Functions::Main::GetBaseDir() . "/temp/' . $file_to_get\n";
		return (KSE::Functions::Main::GetBaseDir() . '/temp/' . $file_to_get);
	}
}

sub GetFileImage
{
	my $file_to_get = shift;
	
#	print "File: $file_to_get\n";
	if(($file_to_get eq '****') or (defined($file_to_get) == 0))
	{ return KSE::Functions::Main::GetBaseDir() . '/no_image.tga'; }
	
	my $path = $Directory{$CurrentDirectory}{'Path'};
	
	if(-e "$path/override" && $Directory{$CurrentDirectory}{'Game'} == 2)
	{
		opendir OVERDIR, "$path/override";
		my @folders = grep { !(/\\\.+$/) && -d } map {"$path/override/$_"} readdir(OVERDIR);
		closedir OVERDIR;
		
		foreach my $folder (@folders)
		{
			if(-e "$path/override/$folder/$file_to_get.tga")
			{
				return "$path/override/$folder/$file_to_get.tga";
			}
			elsif(-e "$path/override/$folder/$file_to_get.tpc")
			{
				my $TPC_obj = Bioware::TPC->new();
				$TPC_obj->read_tpc("$path/override/$folder/$file_to_get.tpc");
				$TPC_obj->write_tga(KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga");
				
				$TPC_obj = undef;
				
				return KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga";
			}
		}
	}
	
	if(-e "$path/override/$file_to_get.tga")
	{
		return "$path/override/$file_to_get.tga";
	}
	elsif(-e "$path/override/$file_to_get.tpc")
	{
		my $TPC_obj = Bioware::TPC->new();
		$TPC_obj->read_tpc("$path/override/$file_to_get.tpc");
		$TPC_obj->write_tga(KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga");
		
		$TPC_obj = undef;
		
		return KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga";
	}
	else
	{
		my $TPC_ERF = Bioware::ERF->new();
		$TPC_ERF->read_erf("$path/texturepacks/swpc_tex_gui.erf");
		my $answer = $TPC_ERF->export_resource("$file_to_get.tpc", KSE::Functions::Main::GetBaseDir() . '/temp/');
		
#		print "Answer: $answer File: $file_to_get.tpc\n";
		$TPC_ERF = undef;
		
		if($answer != 0)
		{
			my $TPC_obj = Bioware::TPC->new();
			$TPC_obj->read_tpc(KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tpc");
			$TPC_obj->write_tga(KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga");
			
			$TPC_obj = undef;
			
			return KSE::Functions::Main::GetBaseDir() . "/temp/$file_to_get.tga";
		}
		else
		{
			return KSE::Functions::Main::GetBaseDir() . '/no_image.tga';
		}
	}
}

sub GetGamePath
{
	return $Directory{$CurrentDirectory}{'Path'};
}

return 1;