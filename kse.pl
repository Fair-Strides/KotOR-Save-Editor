# KSE as designed in Perl...
# Main script. Will use libraries KSE::GUI::Main and KSE::Functions::Main.
###############################################################################
# TO DO LIST:
# -----------
#	1. Test saving functionality (fixed the alignment issue, but am not sure if there might be other issues...)
#	3. Keyboard Shortcuts for menus.
#
###############################################################################
#use experimental qw/smartmatch autoderef switch/;

use Config::IniMan;
use Cwd;

use File::Path;

use KSE::Data;
use KSE::Functions::Main;
use KSE::Functions::Directory;
use KSE::GUI::Main;

my $base       = getcwd;
mkdir("$base/temp");

my $main_ini   = Config::IniMan->new("$base/kse_config.ini");
if(-e "$base/kse_config.ini") { KSE::Functions::Main::LoadPathINI(); }

my $build_menu = KSE::Functions::Directory::GetPathCount();
my $answer     = 0;

#KSE::Functions::Main::Set_Base($base);
#KSE::GUI::Main::Set_Base($base);

my ($GUI, $options) = KSE::GUI::Main::CreateMain(%{$main_ini->get_section()});

foreach (keys %{$options})
{ unless ($_ eq '') { $main_ini->set($_, $options->{$_}); } }

if($build_menu <= 0)
{
	KSE::GUI::Main::ShowMainWindow();
	KSE::GUI::Main::WithdrawMainWindow();
	KSE::GUI::Directory::ShowAddFirstPath($GUI->{DirectoryFrame});
	KSE::GUI::Main::ShowMainWindow();
	
	if(KSE::Functions::Directory::GetPathCount() == -1)
	{
		ExitPopup();
	}
}

KSE::GUI::Main::remake_game_menuitems();
KSE::GUI::Main::PopulatePaths();
KSE::GUI::Main::AdjustTitle('Path', KSE::Functions::Directory::GetGamePath());

KSE::GUI::Main::PopulateSaves(KSE::Functions::Saves::GetAllSaves(KSE::Functions::Directory::GetPathPath(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathGame(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathCloud(KSE::Functions::Directory::GetCurrentDirectory())));

$GUI->{mw}->MainLoop();

#my ($ggame, $gpath) = TSLPatcher::Functions::GetPathForIni();
#$main_ini->set("KotOR$ggame", $gpath);
#$main_ini->write("$base/tslpatcher.ini");

sub ExitPopup
{
	$GUI->{mw}->Dialog(-title=>'No paths to process saved games',
		-text=>'No KotOR 1 or KotOR 2 path was entered, so KSE can\'t find any saves to edit. Please run the KPF tool or manually enter a path when you start KSE again.',
		-default_button=>'Ok',
		-buttons=>['Ok'])->Show();
	
	exit;
}