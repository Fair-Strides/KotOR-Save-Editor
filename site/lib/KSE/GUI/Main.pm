#line 1 "KSE/GUI/Main.pm"
package KSE::GUI::Main;

use KSE::GUI::Alignment;
use KSE::GUI::Appearance;
use KSE::GUI::Classes;
use KSE::GUI::Equipment;
use KSE::GUI::GameControls;
use KSE::GUI::Globals;
use KSE::GUI::Feats;
use KSE::GUI::Inventory;
use KSE::GUI::Journal;
use KSE::GUI::NPC;
use KSE::GUI::Portrait;
use KSE::GUI::Powers;
use KSE::GUI::RadioOptionsControls;		#Gender, CheatUsed, Min1HP, CurrentParty
use KSE::GUI::SpinboxControls;			#TimePlayed, Attributes, HitPoints, ForcePoints, Skills
use KSE::GUI::Soundset;
use KSE::GUI::Target;
use KSE::GUI::TextEntryControls;		#SaveGameName, Area, LastModule, FirstName

use List::Util qw(min max);

use Tk;
use Tk::Adjuster;
use Tk::Button;
use Tk::HList;
use Tk::NoteBook;
use Tk::Panedwindow;
use Tk::ProgressBar;
use Tk::Pane;

my $base		= undef;
my $height		= undef;
my $width		= undef;
my $icon		= undef;
my %GUI			= ();
my $saves_shown	= 0;
my $saves_name	= 0;
my $language_id	= 0;
my $path_open	= 0;
my $popupbox	= undef;

my $def_but_color	= 'SystemButtonFace';
my $act_but_color	= "#A6a6A6";
my $act_but_color2	= "#C6C6C6";
my $sizef = undef;
my $sizeh = undef;
my $sizew = undef;

my $title_base = 'KotOR 1 and 2 Save Game Editor';
my $title_path = undef;
my $title_save = undef;

sub Set_Base { $base = shift; }
sub Set_Icon { my $window = shift; $window->Icon(-image=>$icon); }
sub Set_Saves_Shown { $saves_shown = shift; }
sub Get_Saves_Shown { return $saves_shown;  }
sub Set_Saves_Name	{ $saves_name = KSE::Functions::Saves::Get_Saves_Name(); }
sub Get_Saves_Name  { return $saves_name;	}

sub file_menuitems;
sub option_menuitems;
sub option_languageitems;
sub game_menuitems;
sub help_menuitems;
sub GetPathOpen;
sub SetPathOpen;

# Menu Commands
sub bind_menuitems
{
	
#	$GUI{mw}->bind('<Control-,>'=>sub
#	{
#		print "Sash Coord: " . join(', ', $GUI{MasterFrame}->sashCoord(0)) . ".\n";
#	});

	$GUI{MasterFrame}->bind('<Double-ButtonRelease-1>'=>sub
	{
		# If SavesFrame is open, we want (537,2)
		# If SavesFrame is closed, we want (277,2)
		if($saves_shown == 0)	{ $GUI{MasterFrame}->sashPlace(0, 277, 2); }
		else					{ $GUI{MasterFrame}->sashPlace(0, 537, 2); }
	});
		
	$GUI{mw}->bind('<Control-k>'=>sub
	{
		system 'KPF.exe';
	});
	$GUI{mw}->bind('<Control-h>'=>sub
	{
		if($saves_shown == 0)	{ $saves_shown = 1; }
		else					{ $saves_shown = 0; }
		ToggleSavesFrame();
	});
	$GUI{mw}->bind('<Control-u>'=>sub
	{
		if($saves_name == 0)	{ $saves_name = 1; }
		else					{ $saves_name = 0; }
		KSE::Functions::Saves::Set_Saves_Name($saves_name);
	});
	$GUI{mw}->bind('<F5>'=>sub
	{
		KSE::GUI::Main::PopulateSaves(KSE::Functions::Saves::GetAllSaves(KSE::Functions::Directory::GetPathPath(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathGame(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathCloud(KSE::Functions::Directory::GetCurrentDirectory())));
	});
	$GUI{mw}->bind('<Control-s>'=>sub
	{
		my $file_menu=$menubar->entrycget('File',-menu);
		my $state=$file_menu->entrycget('~Save Game',-state);
		if ($state eq 'normal') { KSE::Functions::Saves::SaveSave(); }
	});
	$GUI{mw}->bind('<Control-e>'=>sub
	{
		my $file_menu=$menubar->entrycget('File',-menu);
		my $state=$file_menu->entrycget('Clos~e Game',-state);
		if ($state eq 'normal') { KSE::Functions::Saves::UnloadSave(); }
	});
	$GUI{mw}->bind('<Control-r>'=>sub
	{
		my $file_menu=$menubar->entrycget('File',-menu);
		my $state=$file_menu->entrycget('~Reload Game',-state);
		if ($state eq 'normal') { KSE::Functions::Saves::LoadSave($GUI{SavesList}->get(($GUI{SavesList}->curselection)[0])); }
	});
	$GUI{mw}->bind('<Control-q>'=>sub
	{
		ExitCheck();
	});
	$GUI{mw}->bind('<Control-p>'=>sub
	{
		$GUI{DirectoryFrame}{'Widget1'}->ShowDirectory();
	});
	$GUI{mw}->bind('<Control-a>'=>sub
	{
		$GUI{mw}->Dialog(
			-title=>'About KSE',
			-text=>'KSE is a Perl app for modifying saved games for SW:KotOR 1 and 2. It was built using a Perl port of the tcl/Tk GUI system.',
			-default_button=>'Ok',
			-buttons=>['Ok'])->Show();
	});
	$GUI{mw}->bind('<Control-w>'=>sub
	{
		system 1, "start https://deadlystream.com/files/file/503-kotor-savegame-editor/";
	});
	$GUI{mw}->bind('<Control-g>'=>sub
	{
		system 1, "start https://gitlab.com/kotorsge-team/kse";
	});
}

sub file_menuitems
{
	return [
		['command', 'Open ~KPF',		-command=>sub { system 'KPF.exe'; }, -accelerator=>'Ctrl+K'],
		['command', 'Refresh Saves',	-command=>sub { KSE::GUI::Main::PopulateSaves(KSE::Functions::Saves::GetAllSaves(KSE::Functions::Directory::GetPathPath(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathGame(KSE::Functions::Directory::GetCurrentDirectory()), KSE::Functions::Directory::GetPathCloud(KSE::Functions::Directory::GetCurrentDirectory()))); }, -accelerator=>'F5'],
		['command', '~Save Game',		-command=>sub { KSE::Functions::Saves::SaveSave(); }, -accelerator=>'Ctrl+S'],
		['command', 'Clos~e Game',		-command=>sub { KSE::Functions::Saves::UnloadSave(); }, -accelerator=>'Ctrl+C'],
		['command', '~Reload Game',		-command=>sub { KSE::Functions::Saves::LoadSave($GUI{SavesList}->get(($GUI{SavesList}->curselection)[0])); }, -accelerator=>'Ctrl+R'],
		['command', '~Quit',			-command=>sub { ExitCheck(); }, -accelerator=>'Ctrl+Q']
	]
}

sub option_menuitems
{
#		['command', 'Show/~Hide Saves', -command=>sub { if($saves_shown == 0) { $saves_shown = 1; } else { $saves_shown = 0; } ToggleSavesFrame(); }, -accelerator=>'Ctrl+H'],
#		['command', '~Use Save Names', -command=>sub { if(KSE::Functions::Saves::Get_Saves_Name() == 0) { KSE::Functions::Saves::Set_Saves_Name(1); } else { KSE::Functions::Saves::Set_Saves_Name(0); } }, -accelerator=>'Ctrl+U']

	return [
		['checkbutton', 'Show/~Hide Saves', -variable=>\$saves_shown, -onvalue=>1, -offvalue=>0, -command=>sub {
			#if($saves_shown == 0) { $saves_shown = 1; } else { $saves_shown = 0; }
			ToggleSavesFrame(); }, -accelerator=>'Ctrl+H'],
		['checkbutton', '~Use Save Names', -variable=>\$saves_name, -onvalue=>1, -offvalue=>0, -command=>sub { KSE::Functions::Saves::Set_Saves_Name($saves_name); }, -accelerator=>'Ctrl+U'],
		'',
		['cascade','~Language Settings',-menuitems=>option_languageitems,-tearoff=>0]
	]
}

sub option_languageitems
{
   return [
     ['radiobutton', 'English',				-variable=>\$language_id, -value=>0,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'French',				-variable=>\$language_id, -value=>2,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'German',				-variable=>\$language_id, -value=>4,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Italian',				-variable=>\$language_id, -value=>6,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Spanish',				-variable=>\$language_id, -value=>8,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Polish',				-variable=>\$language_id, -value=>10,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Korean',				-variable=>\$language_id, -value=>256,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Simplified Chinese',	-variable=>\$language_id, -value=>258,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Traditional Chinese',	-variable=>\$language_id, -value=>260,	-command=>sub { set_languageid(); } ],
     ['radiobutton', 'Japanese',			-variable=>\$language_id, -value=>262,	-command=>sub { set_languageid(); } ],
   ]
}

sub game_menuitems
{
	return [
		['command', 'Show ~Paths', -command=>sub { $GUI{DirectoryFrame}{'Widget1'}->ShowDirectory(); }, -accelerator=>'Ctrl+P'],
		''
	]
}

sub remake_game_menuitems
{
	$GUI{Menu}->entrycget('Games', '-menu')->delete(0, 'end');
	
	$GUI{Menu}->entrycget('Games', '-menu')->add('command', -label=>'Show ~Paths', -accelerator=>'Ctrl+P', -command=>sub { $GUI{DirectoryFrame}{'Widget1'}->ShowDirectory(); });
	$GUI{Menu}->entrycget('Games', '-menu')->add('separator');
	
	for(my $i = 0; $i < KSE::Functions::Directory::GetPathCount(); $i++)
	{
		$GUI{Menu}->entrycget('Games', '-menu')->add('radiobutton', -indicatoron=>1, -label=>KSE::Functions::Directory::GetPathName($i), -value=>$i, -variable=>\$path_open, -command=> sub
		{
			my $check = KSE::Functions::Saves::SaveCheck();
			if($check > 0)
			{
				if($check == 2)
				{
					KSE::Functions::Saves::SaveSave();
				}
				
				KSE::Functions::Saves::UnloadSave();
				
				KSE::Functions::Directory::SetCurrentDirectory($path_open);
				KSE::GUI::Main::AdjustTitle('Path', KSE::Functions::Directory::GetGamePath());
				
				KSE::Functions::Saves::ResetAllSaves();
				$GUI{SavesList}->delete(0, 'end');
				
				PopulateSaves(KSE::Functions::Saves::GetAllSaves(KSE::Functions::Directory::GetPathPath($path_open), KSE::Functions::Directory::GetPathGame($path_open), KSE::Functions::Directory::GetPathCloud($path_open)))
			}
		});
	}
}

sub help_menuitems
{
	return [
		['command', '~About', -command=> sub
			{
				$GUI{mw}->Dialog(
					-title=>'About KSE',
					-text=>'KSE is a Perl app for modifying saved games for SW:KotOR 1 and 2. It was built using a Perl port of the tcl/Tk GUI system.',
					-default_button=>'Ok',
					-buttons=>['Ok'])->Show();
			}, -accelerator=>'Ctrl+A'
		],
		['command', '~Website', -command=> sub
			{
				system 1, "start https://deadlystream.com/files/file/503-kotor-savegame-editor/";
			}, -accelerator=>'Ctrl+W'
		],
		['command', '~Gitlab', -command=> sub
			{
				system 1, "start https://gitlab.com/kotorsge-team/kse";
			}, -accelerator=>'Ctrl+G'
		]
	]
}

sub set_languageid
{
	KSE::Functions::Main::SetLanguage($language_id);
}

sub GetPathOpen
{
	return $path_open;
}

sub SetPathOpen
{
	$path_open = shift;
}

sub AdjustTitle
{
	my ($piece, $value) = @_;
	
	if($piece eq 'Path')	{ if(defined($value) == 1) { $path_open = KSE::Functions::Directory::GetCurrentDirectory(); $title_path = ' ~ ' . $value; } else { $title_path = undef; } }
	else					{ if(defined($value) == 1) { $title_save = ' ~ ' . $value; } else { $title_save = undef; } }
	
	$GUI{mw}->configure(-title=>$title_base . $title_path  . $title_save);
}

# Main Lists and Controls
sub CreateMain
{
	my %options = shift;
	Set_Saves_Name();
	$language_id = KSE::Functions::Main::GetLanguage();
	
    if(defined($options{Title}) == 0)    { $options{Title} = 'KotOR 1 and 2 Save Game Editor'; }
    if(defined($options{Geometry}) == 0) { $options{Geometry} = '1360x688+0+0'; } #'1024x768'; }
	
	# Begin coding the Main Window, which will also be the window used for mod installation progress.
	$GUI{mw} = Tk::MainWindow->new(-title=>$options{Title});
	$GUI{mw}->geometry($options{Geometry});
	$GUI{mw}->protocol('WM_DELETE_WINDOW', \&ExitCheck);
	$GUI{mw}->resizable(0, 0);
	
	KSE::Functions::Saves::SetMW($GUI{mw});
	$icon = $GUI{mw}->Photo(-file=>"boba.bmp", -format=>'bmp');
	
	Set_Icon($GUI{mw});
	
	$_ = $options{Geometry};
#	print "\$_ is $_.\n";
	/(.*)x(.*?)\+/g;
	$width  = $1;
	$height = $2;
	
	# Master Frame and the various save data categories.
	#$GUI{MasterFrame}	= $GUI{mw}->Frame(-height=>$height, -width=>$width)->pack(-fill=>'both');
	$GUI{MasterFrame}	= $GUI{mw}->Panedwindow(-handlepad=>25, -handlesize=>5, -opaqueresize=>1, -sashrelief=>'groove', -sashpad=>2, -sashwidth=>5, -showhandle=>0, -orient=>'horizontal')->pack(-fill=>'both', -expand=>1);
#	$GUI{MasterFrame}	= $GUI{mw}->Frame()->pack(-fill=>'both', -expand=>1);
	$GUI{LeftFrame}		= $GUI{MasterFrame}->Frame(-height=>$height, -width=>300)->pack(-side=>'left', -fill=>'x', -padx=>10, -pady=>15, -expand=>1);
#	$GUI{ControlsFrame}	= $GUI{LeftFrame}->Frame(-height=>$height, -width=>300)->pack(-side=>'left', -fill=>'x', -padx=>10, -pady=>15);
#	$GUI{Adjuster}		= $GUI{MasterFrame}->Adjuster(-side=>'left')->packAfter($GUI{ControlsFrame}, -side=>'left');
	
	# The container frame for editing the save data
	$GUI{PanelFrame}	= $GUI{MasterFrame}->Frame(-height=>$height, -width=>1000)->pack(-side=>'left', -anchor=>'e', -fill=>'both', -pady=>15, -expand=>1);
	$GUI{TargetFrame}	= KSE::GUI::Target->new();
	$GUI{TargetFrame}->Create($GUI{PanelFrame});
	
	$GUI{ControlsList}	= $GUI{PanelFrame}->NoteBook(-font=>[-family=>'Helvitica', -size=>16], -tabpadx=>23, -borderwidth=>0, -backpagecolor=>$act_but_color)->pack(-fill=>'both', -pady=>5);
	$GUI{'Panels'}{'General'}{'Frame'}		= $GUI{ControlsList}->add('General',	-anchor=>'center', -label=>'General',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('General'); });
	$GUI{'Panels'}{'Globals'}{'Frame'}		= $GUI{ControlsList}->add('Globals',	-anchor=>'center', -label=>'Variables',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Globals'); });
	$GUI{'Panels'}{'Inventory'}{'Frame'}	= $GUI{ControlsList}->add('Inventory',	-anchor=>'center', -label=>'Inventory',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Inventory'); });
	$GUI{'Panels'}{'Journal'}{'Frame'}		= $GUI{ControlsList}->add('Journal',	-anchor=>'center', -label=>'Journal',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Journal'); });
	$GUI{'Panels'}{'Stats'}{'Frame'}		= $GUI{ControlsList}->add('Stats',		-anchor=>'center', -label=>'Stats',		-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Stats'); });
	$GUI{'Panels'}{'Classes'}{'Frame'}		= $GUI{ControlsList}->add('Classes',	-anchor=>'center', -label=>'Classes',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Classes'); });
	$GUI{'Panels'}{'Feats'}{'Frame'}		= $GUI{ControlsList}->add('Feats',		-anchor=>'center', -label=>'Feats',		-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Feats'); });
	$GUI{'Panels'}{'Powers'}{'Frame'}		= $GUI{ControlsList}->add('Powers',		-anchor=>'center', -label=>'Powers',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Powers'); });
	$GUI{'Panels'}{'Equipment'}{'Frame'}	= $GUI{ControlsList}->add('Equipment',	-anchor=>'center', -label=>'Equipment',	-justify=>'center', -state=>'normal', -raisecmd=>sub { ShowPanel('Equipment'); });
	
	# The frame for loading different saves
	$GUI{SavesFrame}	= $GUI{LeftFrame}->Frame(-height=>$height, -width=>300);	
	$GUI{SavesList}		= $GUI{SavesFrame}->Scrolled('Listbox', -scrollbars=>'osoe', -selectmode=>'browse', -activestyle=>'none', -font=>[-family=>'Lucida Console Regular', -size=>15], -height=>26, -width=>20)->pack(-fill=>'both');
	$GUI{SavesList}->bind('<Double-ButtonPress-1>'=>sub
	{
		my $check = KSE::Functions::Saves::SaveCheck();
		$GUI{SavesIndex} = ($GUI{SavesList}->curselection)[0];
#		print "Gui SavesIndex is " . $GUI{SavesIndex} . "\n";
		
		if($check > 0)
		{
			if($check == 2)
			{
				KSE::Functions::Saves::SaveSave();
			}
			
			KSE::Functions::Saves::UnloadSave();
			
			KSE::Functions::Saves::LoadSave($GUI{SavesList}->get(($GUI{SavesList}->curselection)[0]));
			EnableControls();
		}
		
#		print "Clearing selection from 0 to " . max(0, ($GUI{SavesIndex}-1)) . "\n";
		$GUI{SavesList}->selectionClear(0, $GUI{SavesList}->index('end'));
		$GUI{SavesList}->selectionSet($GUI{SavesIndex},$GUI{SavesIndex});
##		print "Clearing selection from " . min(($GUI{SavesIndex} + 1), $GUI{SavesList}->index('end')) . " to " . $GUI{SavesList}->index('end') . "\n";
##		$GUI{SavesList}->selectionClear(min(($GUI{SavesIndex} + 1), $GUI{SavesList}->index('end')), ($GUI{SavesList}->index('end')-1));
	});
	$GUI{SavesList}->bind('<Return>'=>sub
	{
		my $check = KSE::Functions::Saves::SaveCheck();
		$GUI{SavesIndex} = ($GUI{SavesList}->curselection)[0];
		
		if($check > 0)
		{
			if($check == 2)
			{
				KSE::Functions::Saves::SaveSave();
			}
			
			KSE::Functions::Saves::UnloadSave();
			
			KSE::Functions::Saves::LoadSave($GUI{SavesList}->get(($GUI{SavesList}->curselection)[0]));
			EnableControls();
		}
		
		$GUI{SavesList}->selectionClear(0, 'end');
#		$GUI{SavesList}->selectionSet($GUI{SavesIndex}, $GUI{SavesIndex});
	});
	
	# The window for adding and editing new game directories
	$GUI{DirectoryFrame} = KSE::GUI::Directory->new();
	$GUI{DirectoryFrame}{'Widget1'} = KSE::GUI::Directory::Create($GUI{DirectoryFrame}, $GUI{mw});
		
	$GUI{MasterFrame}->add($GUI{LeftFrame}, -minsize=>277);
	$GUI{MasterFrame}->add($GUI{PanelFrame});

	ToggleSavesFrame();
	
	# The menu, such as switching game directories
	$GUI{Menu} = $GUI{mw}->Menu();
	$GUI{Menu}{File}	= $GUI{Menu}->cascade(-label=>'~File',		-tearoff=>0, -menuitems=>file_menuitems);
	$GUI{Menu}{Options} = $GUI{Menu}->cascade(-label=>'~Options',	-tearoff=>0, -menuitems=>option_menuitems);
	$GUI{Menu}{Games}	= $GUI{Menu}->cascade(-label=>'~Games',		-tearoff=>0, -menuitems=>game_menuitems);
	$GUI{Menu}{Help}	= $GUI{Menu}->cascade(-label=>'~Help',		-tearoff=>0, -menuitems=>help_menuitems);
	
	$GUI{mw}->configure(-menu=>$GUI{Menu});
#	$GUI{mw}->bind('<Key>'=>[sub { my ($w, $key) = @_; print "Key Code: $key\n"; }, Ev('K')]);
	DisableControls();
	
	bind_menuitems();
	
	return \%GUI, %options;
}

sub DisableControls
{
#	foreach(1 .. 9)
#	{
#		$GUI{'ControlsButton0' . $_}->configure(-state=>'disabled');
#	}
#	$GUI{'ControlsButton10'}->configure(-state=>'disabled');

	foreach($GUI{ControlsList}->pages)
	{
		$GUI{ControlsList}->pageconfigure($_, -state=>'disabled');
	}	
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(3, -state=>'disabled');
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(4, -state=>'disabled');
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(5, -state=>'disabled');
}

sub EnableControls
{
#	foreach(1 .. 9)
#	{
#		$GUI{'ControlsButton0' . $_}->configure(-state=>'normal');
#	}
#	$GUI{'ControlsButton10'}->configure(-state=>'normal');
	
	foreach($GUI{ControlsList}->pages)
	{
		$GUI{ControlsList}->pageconfigure($_, -state=>'normal');
	}
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(3, -state=>'normal');
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(4, -state=>'normal');
	$GUI{Menu}->entrycget('File', -menu)->entryconfigure(5, -state=>'normal');
}

sub RemoveNPCControls
{
#	foreach my $path ($GUI{ControlsList}->info('children', 'Control06'))
#	{
#		$GUI{ControlsList}->delete('entry', $path);
#		
#		my $p = (split(/\#/, $path))[-1];
#		
#		$GUI{'ControlsButton06_' . $p}->destroy;
#	}
}

# Panels
sub CreateGeneralPanel
{
	SetResourceStep('Creating General layout frames.');
	
#	$GUI{'Panels'}{'General'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'General Settings', -labelside=>'acrosstop', -height=>$height-30, -width=>1070);
	$GUI{'Panels'}{'General'}{'Frame'} = $GUI{ControlsList}->page_widget('General');
	SetResourceProgress(5);
	
	$GUI{'Panels'}{'General'}{'Frame'}{'FrameT'} = $GUI{'Panels'}{'General'}{'Frame'}->Frame()->pack(-side=>'top', -fill=>'x', -expand=>1);
	$GUI{'Panels'}{'General'}{'Frame'}{'FrameB'} = $GUI{'Panels'}{'General'}{'Frame'}->Frame()->pack(-side=>'bottom', -fill=>'x', -expand=>1);
	SetResourceProgress(15);
	
	$GUI{'Panels'}{'General'}{'Frame'}{'FrameT1'} = $GUI{'Panels'}{'General'}{'Frame'}{'FrameT'}->Frame()->pack(-side=>'left', -fill=>'y', -expand=>1);
	$GUI{'Panels'}{'General'}{'Frame'}{'FrameT2'} = $GUI{'Panels'}{'General'}{'Frame'}{'FrameT'}->Frame()->pack(-side=>'left', -fill=>'y', -expand=>1);
	$GUI{'Panels'}{'General'}{'Frame'}{'FrameT3'} = $GUI{'Panels'}{'General'}{'Frame'}{'FrameT'}->Frame()->pack(-side=>'left', -fill=>'y', -expand=>1);
	
###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	
	SetResourceProgress(20);
	SetResourceStep('Creating General Data controls.');
	$GUI{'Panels'}{'General'}{'Widget1'} = KSE::GUI::TextEntryControls->new('None', $game);
	$GUI{'Panels'}{'General'}{'Widget2'} = KSE::GUI::RadioOptionsControls->new('None', $game);
	$GUI{'Panels'}{'General'}{'Widget3'} = KSE::GUI::SpinboxControls->new('None', $game);
	SetResourceProgress(30);
	
	$GUI{'Panels'}{'General'}{'Widget1'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameT1'}, 'SaveGameName', 'Area', 'LastModule');
	SetResourceProgress(51);
	$GUI{'Panels'}{'General'}{'Widget2'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameT2'}, 'CheatUsed', 'SoloMode');
	SetResourceProgress(65);
	$GUI{'Panels'}{'General'}{'Widget3'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameT2'}, 'TimePlayed');
	SetResourceProgress(72);
	$GUI{'Panels'}{'General'}{'Widget3'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameT3'}, 'Credits', 'XP', 'Party XP');
	SetResourceProgress(90);
	$GUI{'Panels'}{'General'}{'Widget2'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameB'}, 'CurrentParty');
	SetResourceProgress(95);
	
	if($game == 2)
	{
		$GUI{'Panels'}{'General'}{'Widget3'}->Create($GUI{'Panels'}{'General'}{'Frame'}{'FrameT3'}, 'Components', 'Chemicals');
	}
	SetResourceProgress(100);
}

sub CreateGlobalsPanel
{
	SetResourceProgress(0);
	SetResourceStep('Creating Global Variable layout frames.');
#	$GUI{'Panels'}{'Globals'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Global Variables', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Globals'}{'Frame'} = $GUI{ControlsList}->page_widget('Globals');

###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	SetResourceProgress(10);
	
	$GUI{'Panels'}{'Globals'}{'Widget1'} = KSE::GUI::Globals->new($game);
	$GUI{'Panels'}{'Globals'}{'Widget1'}->Create($GUI{'Panels'}{'Globals'}{'Frame'});
	SetResourceProgress(100);
}

sub CreateInventoryPanel
{
#	$GUI{'Panels'}{'Inventory'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Inventory Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Inventory'}{'Frame'} = $GUI{ControlsList}->page_widget('Inventory');
	
###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	
	$GUI{'Panels'}{'Inventory'}{'Widget1'} = KSE::GUI::Inventory->new($game);
	$GUI{'Panels'}{'Inventory'}{'Widget1'}->Create($GUI{'Panels'}{'Inventory'}{'Frame'});
}

sub CreateJournalPanel
{
	SetResourceStep('Creating Journal layout frames.');
	SetResourceProgress(0);
#	$GUI{'Panels'}{'Journal'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Journal', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Journal'}{'Frame'} = $GUI{ControlsList}->page_widget('Journal');
	SetResourceProgress(10);
	
###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	
	$GUI{'Panels'}{'Journal'}{'Widget1'} = KSE::GUI::Journal->new($game);
	$GUI{'Panels'}{'Journal'}{'Widget1'}->Create($GUI{'Panels'}{'Journal'}{'Frame'});
	SetResourceProgress(100);
}

sub CreateStatsPanel
{
	SetResourceStep('Creating Player/Party Member layout frame.');
	SetResourceProgress(0);
	$GUI{'Panels'}{'Stats'}{'Frame'} = $GUI{ControlsList}->page_widget('Stats');
	
	$GUI{'Panels'}{'Stats'}{'Base'}		= $GUI{'Panels'}{'Stats'}{'Frame'}->Scrolled('Frame', -scrollbars=>'oe', -height=>$height-30, -width=>800, -padx=>5)->pack(-fill=>'both', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'Main'}		= $GUI{'Panels'}{'Stats'}{'Base'}->Frame(-height=>$height-30, -width=>300)->pack(-fill=>'y', -side=>'left', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'AppMain'}	= $GUI{'Panels'}{'Stats'}{'Base'}->Frame(-height=>$height-30, -width=>400)->pack(-fill=>'y', -anchor=>'n', -side=>'right', -expand=>1);
	
	$GUI{'Panels'}{'Stats'}{'Main1'}	= $GUI{'Panels'}{'Stats'}{'Main'}->Frame(-height=>25, -width=>250)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'Main2'}	= $GUI{'Panels'}{'Stats'}{'Main'}->Frame(-height=>60, -width=>250)->pack(-fill=>'x', -pady=>10, -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'Main3'}	= $GUI{'Panels'}{'Stats'}{'Main'}->Frame(-height=>25, -width=>250)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'Main4'}	= $GUI{'Panels'}{'Stats'}{'Main'}->Frame(-height=>25, -width=>300)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'AppMain1'}	= $GUI{'Panels'}{'Stats'}{'AppMain'}->Frame(-height=>25, -width=>40)->pack(-fill=>'x', -anchor=>'s', -expand=>1);
	$GUI{'Panels'}{'Stats'}{'AppMain2'}	= $GUI{'Panels'}{'Stats'}{'AppMain'}->Frame(-height=>200, -width=>40)->pack(-fill=>'y', -anchor=>'n', -expand=>1);
	SetResourceProgress(10);
	
###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	
	$GUI{'Panels'}{'Stats'}{'Widget1'} = KSE::GUI::TextEntryControls->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget2'} = KSE::GUI::RadioOptionsControls->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget3'} = KSE::GUI::SpinboxControls->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget4'} = KSE::GUI::Appearance->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget5'} = KSE::GUI::Portrait->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget6'} = KSE::GUI::Soundset->new('Stats', $game);
	$GUI{'Panels'}{'Stats'}{'Widget7'} = KSE::GUI::Alignment->new('Stats', $game);
	SetResourceProgress(20);
	
	if($game == 2)
	{
		SetResourceStep('Creating Player/Party Member Influence widget.');
		$GUI{'Panels'}{'Stats'}{'Widget3'}->Create($GUI{'Panels'}{'Stats'}{'AppMain1'}, 'Influence');
	}
	SetResourceProgress(30);
	
	SetResourceStep('Creating Player/Party Member Name widget.');
	$GUI{'Panels'}{'Stats'}{'Widget1'}->Create($GUI{'Panels'}{'Stats'}{'Main1'}, 'FirstName');
	SetResourceProgress(40);
	SetResourceStep('Creating Player/Party Member Soundset widget.');
	$GUI{'Panels'}{'Stats'}{'Widget6'}->Create($GUI{'Panels'}{'Stats'}{'Main1'});
	SetResourceProgress(50);
	SetResourceStep('Creating Player/Party Member Alignment widget.');
	$GUI{'Panels'}{'Stats'}{'Widget7'}->Create($GUI{'Panels'}{'Stats'}{'Main1'});
	SetResourceProgress(60);
	
	SetResourceStep('Creating Player/Party Member Toggle widgets.');
	$GUI{'Panels'}{'Stats'}{'Widget2'}->Create($GUI{'Panels'}{'Stats'}{'Main2'}, 'Gender', 'Min1HP');
	SetResourceProgress(70);
	
	SetResourceStep('Creating Player/Party Member Portraits widget.');
	$GUI{'Panels'}{'Stats'}{'Widget5'}->Create($GUI{'Panels'}{'Stats'}{'Main3'});
	SetResourceProgress(80);
	SetResourceStep('Creating Player/Party Member Hit point and Force point widgets.');
	$GUI{'Panels'}{'Stats'}{'Widget3'}->Create($GUI{'Panels'}{'Stats'}{'Main3'}, 'HitPoints', 'ForcePoints');
	SetResourceProgress(90);
	
	SetResourceStep('Creating Player/Party Member Ability Score and Skill widgets.');
	$GUI{'Panels'}{'Stats'}{'Widget3'}->Create($GUI{'Panels'}{'Stats'}{'Main4'}, 'Attributes', 'Skills');
	SetResourceProgress(95);
	
	SetResourceStep('Creating Player/Party Member Appearance widget.');
	$GUI{'Panels'}{'Stats'}{'Widget4'}->Create($GUI{'Panels'}{'Stats'}{'AppMain2'});
	SetResourceProgress(100);
}

sub ChangeTargetStats
{
	my $target = shift;
	print "Target: $target\n1\n";
	$GUI{'Panels'}{'Stats'}{'Widget1'}->ChangeTarget($target, 'FirstName');
	print "2\n";
	$GUI{'Panels'}{'Stats'}{'Widget2'}->ChangeTarget($target, 'Gender', 'Min1HP');
	print "3\n";
	$GUI{'Panels'}{'Stats'}{'Widget3'}->ChangeTarget($target, 'Attributes', 'Skills', 'Influence', 'HitPoints', 'ForcePoints');
	print "4\n";
	$GUI{'Panels'}{'Stats'}{'Widget4'}->ChangeTarget($target);
	print "5\n";
	$GUI{'Panels'}{'Stats'}{'Widget5'}->ChangeTarget($target);
	print "6\n";
	$GUI{'Panels'}{'Stats'}{'Widget6'}->ChangeTarget($target);
	print "7\n";
	$GUI{'Panels'}{'Stats'}{'Widget7'}->ChangeTarget($target);
	
}

sub CreatePlayerPanel
{
	$GUI{'Panels'}{'Player'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Player Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);

	$GUI{'Panels'}{'Player'}{'Base'}		= $GUI{'Panels'}{'Player'}{'Frame'}->Scrolled('Frame', -scrollbars=>'oe', -height=>$height-30, -width=>800, -padx=>5)->pack(-fill=>'both', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Player'}{'Main'}		= $GUI{'Panels'}{'Player'}{'Base'}->Frame(-height=>$height-30, -width=>300)->pack(-fill=>'y', -side=>'left', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Player'}{'Appearance'}	= $GUI{'Panels'}{'Player'}{'Base'}->Frame(-height=>$height-30, -width=>400)->pack(-fill=>'y', -anchor=>'n', -side=>'right', -expand=>1);
	
	$GUI{'Panels'}{'Player'}{'Main1'}		= $GUI{'Panels'}{'Player'}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Player'}{'Main2'}		= $GUI{'Panels'}{'Player'}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -pady=>10, -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Player'}{'Main3'}		= $GUI{'Panels'}{'Player'}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	$GUI{'Panels'}{'Player'}{'Main4'}		= $GUI{'Panels'}{'Player'}{'Main'}->Frame(-height=>$height-30, -width=>300)->pack(-fill=>'x', -anchor=>'n', -expand=>1);
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
	$GUI{'Panels'}{'Player'}{'Widget1'} = KSE::GUI::TextEntryControls->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget2'} = KSE::GUI::RadioOptionsControls->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget3'} = KSE::GUI::SpinboxControls->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget4'} = KSE::GUI::Appearance->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget5'} = KSE::GUI::Portrait->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget6'} = KSE::GUI::Soundset->new('Player', $game);
	$GUI{'Panels'}{'Player'}{'Widget7'} = KSE::GUI::Alignment->new('Player', $game);
	
	$GUI{'Panels'}{'Player'}{'Widget1'}->Create($GUI{'Panels'}{'Player'}{'Main1'}, 'FirstName');
	$GUI{'Panels'}{'Player'}{'Widget6'}->Create($GUI{'Panels'}{'Player'}{'Main1'});
	$GUI{'Panels'}{'Player'}{'Widget7'}->Create($GUI{'Panels'}{'Player'}{'Main1'});
	
	$GUI{'Panels'}{'Player'}{'Widget2'}->Create($GUI{'Panels'}{'Player'}{'Main2'}, 'Gender', 'Min1HP');
	
	$GUI{'Panels'}{'Player'}{'Widget5'}->Create($GUI{'Panels'}{'Player'}{'Main3'});
	$GUI{'Panels'}{'Player'}{'Widget3'}->Create($GUI{'Panels'}{'Player'}{'Main3'}, 'HitPoints', 'ForcePoints');

	$GUI{'Panels'}{'Player'}{'Widget3'}->Create($GUI{'Panels'}{'Player'}{'Main4'}, 'Attributes', 'Skills');
	
	$GUI{'Panels'}{'Player'}{'Widget4'}->Create($GUI{'Panels'}{'Player'}{'Appearance'});
}

sub CreateNPCsPanel
{
	$GUI{'Panels'}{'NPCs'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Party Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);

	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());

	$GUI{'Panels'}{'NPCs'}{'Widget1'} = KSE::GUI::NPC->new('Main', $game, sub { my $npc = shift; ShowPanel('NPCs' . $npc); });
	$GUI{'Panels'}{'NPCs'}{'Widget1'}->Create($GUI{'Panels'}{'NPCs'}{'Frame'});
}

sub CreateNPC_NumPanel
{
	my $num = shift;
	
	$GUI{'ControlsButton06_' . $num} = $GUI{ControlsList}->Button(-text=>'NPC - ' . KSE::Functions::NPC::GetName($num),		-relief=>'flat', -activebackground=>$act_but_color2, -width=>$sizew, -height=>$sizeh, -font=>[-family=>'Helvitica', -size=>$sizef], -command=>sub { ShowPanel('NPCs' . $num); });

	my $branch = '';
	foreach my $index (reverse(0 .. 12))
	{
		next if $index >= $num;
		
		if($GUI{ControlsList}->info('exists', 'Control06#' . $index))
		{
			$branch = $index;
			last;
		}
	}
	
	if($branch eq '')
	{
		$GUI{ControlsList}->add('Control06#' . $num, -widget=>$GUI{'ControlsButton06_' . $num});
	}
	else
	{
		$GUI{ControlsList}->add('Control06#' . $num, -widget=>$GUI{'ControlsButton06_' . $num}, -after=>'Control06#' . $branch);
	}
	
	$GUI{'Panels'}{'NPCs' . $num}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'NPC' . $num . ' Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);

	$GUI{'Panels'}{'NPCs' . $num}{'Base'}		= $GUI{'Panels'}{'NPCs' . $num}{'Frame'}->Scrolled('Frame', -scrollbars=>'oe', -height=>$height-30, -width=>800, -padx=>5)->pack(-fill=>'both', -anchor=>'n');
	$GUI{'Panels'}{'NPCs' . $num}{'Main'}		= $GUI{'Panels'}{'NPCs' . $num}{'Base'}->Frame(-height=>$height-30, -width=>300)->pack(-fill=>'y', -side=>'left', -anchor=>'n');
	$GUI{'Panels'}{'NPCs' . $num}{'Appearance'}	= $GUI{'Panels'}{'NPCs' . $num}{'Base'}->Frame(-height=>$height-30, -width=>400)->pack(-fill=>'y', -anchor=>'n', -side=>'right');
	
	$GUI{'Panels'}{'NPCs' . $num}{'Main1'}		= $GUI{'Panels'}{'NPCs' . $num}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -anchor=>'n');
	$GUI{'Panels'}{'NPCs' . $num}{'Main2'}		= $GUI{'Panels'}{'NPCs' . $num}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -pady=>10, -anchor=>'n');
	$GUI{'Panels'}{'NPCs' . $num}{'Main3'}		= $GUI{'Panels'}{'NPCs' . $num}{'Main'}->Frame(-height=>$height-30, -width=>250)->pack(-fill=>'x', -anchor=>'n');
	$GUI{'Panels'}{'NPCs' . $num}{'Main4'}		= $GUI{'Panels'}{'NPCs' . $num}{'Main'}->Frame(-height=>$height-30, -width=>300)->pack(-fill=>'x', -anchor=>'n');
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
	$GUI{'Panels'}{'NPCs' . $num}{'Widget1'} = KSE::GUI::TextEntryControls->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget2'} = KSE::GUI::RadioOptionsControls->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget3'} = KSE::GUI::SpinboxControls->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget4'} = KSE::GUI::Appearance->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget5'} = KSE::GUI::Portrait->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget6'} = KSE::GUI::Soundset->new('NPC' . $num, $game);
	$GUI{'Panels'}{'NPCs' . $num}{'Widget7'} = KSE::GUI::Alignment->new('NPC' . $num, $game);
	
	$GUI{'Panels'}{'NPCs' . $num}{'Widget1'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main1'}, 'FirstName');
	$GUI{'Panels'}{'NPCs' . $num}{'Widget6'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main1'});
	$GUI{'Panels'}{'NPCs' . $num}{'Widget7'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main1'});
	
	if($game == 2)
	{
		$GUI{'Panels'}{'NPCs' . $num}{'Widget3'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Appearance'}, 'Influence');
	}
	
	$GUI{'Panels'}{'NPCs' . $num}{'Widget2'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main2'}, 'Gender', 'Min1HP');
	
	$GUI{'Panels'}{'NPCs' . $num}{'Widget5'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main3'});
	$GUI{'Panels'}{'NPCs' . $num}{'Widget3'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main3'}, 'HitPoints', 'ForcePoints');

	$GUI{'Panels'}{'NPCs' . $num}{'Widget3'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Main4'}, 'Attributes', 'Skills');
	
	$GUI{'Panels'}{'NPCs' . $num}{'Widget4'}->Create($GUI{'Panels'}{'NPCs' . $num}{'Appearance'});

	
	$GUI{'ControlsButton06_' . $num}->configure(-background=>$act_but_color);
}

sub CreateClassesPanel
{
	SetResourceStep('Creating Class Selection layout frames.');
	SetResourceProgress(0);
#	$GUI{'Panels'}{'Classes'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Class Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Classes'}{'Frame'} = $GUI{ControlsList}->page_widget('Classes');
	
###	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	my $game = KSE::Data::GetData('None', 'Game');
	
	$GUI{'Panels'}{'Classes'}{'Widget1'} = KSE::GUI::Classes->new($game);
	
	$GUI{'Panels'}{'Classes'}{'Widget1'}->Create($GUI{'Panels'}{'Classes'}{'Frame'});
	SetResourceProgress(100);
}

sub CreateFeatsPanel
{
	SetResourceStep('Creating Feat Selection layout frames.');
	SetResourceProgress(0);
#	$GUI{'Panels'}{'Feats'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Feat Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Feats'}{'Frame'} = $GUI{ControlsList}->page_widget('Feats');
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
#	$GUI{'Panels'}{'Feats'}{'Widget1'} = KSE::GUI::GameControls->new($game);
	$GUI{'Panels'}{'Feats'}{'Widget3'} = KSE::GUI::Feats->new($game);
	
#	$GUI{'Panels'}{'Feats'}{'Widget1'}->CreatePCorNPCDropdown($GUI{'Panels'}{'Feats'}{'Frame'}, 'Feats');
	$GUI{'Panels'}{'Feats'}{'Widget3'}->Create($GUI{'Panels'}{'Feats'}{'Frame'});
	SetResourceProgress(100);
}

sub CreatePowersPanel
{
	SetResourceStep('Creating Force Power Selection layout frames.');
	SetResourceProgress(0);
#	$GUI{'Panels'}{'Powers'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Force Power Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Powers'}{'Frame'} = $GUI{ControlsList}->page_widget('Powers');
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
#	$GUI{'Panels'}{'Powers'}{'Widget1'} = KSE::GUI::GameControls->new($game);
	$GUI{'Panels'}{'Powers'}{'Widget3'} = KSE::GUI::Powers->new($game);
	
#	$GUI{'Panels'}{'Powers'}{'Widget1'}->CreatePCorNPCDropdown($GUI{'Panels'}{'Powers'}{'Frame'}, 'Powers');
	$GUI{'Panels'}{'Powers'}{'Widget3'}->Create($GUI{'Panels'}{'Powers'}{'Frame'});
	SetResourceProgress(100);
}

sub CreateEquipmentPanel
{
	SetResourceStep('Creating Equipment Selection layout frames.');
	SetResourceProgress(0);

#	$GUI{'Panels'}{'Equipment'}{'Frame'} = $GUI{PanelFrame}->LabFrame(-label=>'Equipment Management', -labelside=>'acrosstop', -height=>$height-30, -width=>970);
	$GUI{'Panels'}{'Equipment'}{'Frame'} = $GUI{ControlsList}->page_widget('Equipment');
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
	$GUI{'Panels'}{'Equipment'}{'Widget2'} = KSE::GUI::Equipment->new($game);
	$GUI{'Panels'}{'Equipment'}{'Widget2'}->Create($GUI{'Panels'}{'Equipment'}{'Frame'});
	SetResourceProgress(100);
}

sub CreatePanel
{
	my $panel = shift;
	if(defined($GUI{'Exists'}{$panel}) == 0)
	{
		$GUI{'Exists'}{$panel} = 0;
	}
	if($GUI{'Exists'}{$panel} == 0)
	{
		$GUI{'Exists'}{$panel} = 1;
		
		if($panel eq 'General') 			{ CreateGeneralPanel();			}
		elsif($panel eq 'Globals')			{ CreateGlobalsPanel();			}
#		elsif($panel eq 'Global Numbers')	{ CreateGlobalNumbersPanel();	}
#		elsif($panel eq 'Global Booleans')	{ CreateGlobalBoolsPanel(); 	}
		elsif($panel eq 'Inventory')		{ CreateInventoryPanel();		}
		elsif($panel eq 'Journal')			{ CreateJournalPanel();			}
		elsif($panel eq 'Stats')			{ CreateStatsPanel();			}
		elsif($panel eq 'Player')			{ CreatePlayerPanel();			}
		elsif($panel eq 'NPCs')				{ CreateNPCsPanel();			}
		elsif($panel =~ /NPCs(\d*)/)		{ CreateNPC_NumPanel($1);		}
		elsif($panel eq 'Classes')			{ CreateClassesPanel();			}
		elsif($panel eq 'Feats')			{ CreateFeatsPanel();			}
		elsif($panel eq 'Powers')			{ CreatePowersPanel();			}
		elsif($panel eq 'Equipment')		{ CreateEquipmentPanel();		}
	}
}

sub DeleteAllPanels
{
	foreach my $panel (sort {$a cmp $b} keys %{$GUI{'Panels'}})
	{
		delete $GUI{'Exists'}{$panel};
		
#		foreach my $widget (sort {$a cmp $b} keys %{$GUI{'Panels'}{$panel}})
#		{
#			next if $widget =~ /^Frame$/;
#			
#			print "\t$widget\n";
#			$GUI{'Panels'}{$panel}{$widget}->destroy;
#		}
#		$GUI{'Panels'}{$panel}{'Frame'}->destroy;
		
		delete $GUI{'Panels'}{$panel};
	}
	
#	foreach my $num (1 .. 9)
#	{
#		$GUI{'ControlsButton0' . $num}->configure(-background=>$def_but_color);
#	}
#	$GUI{'ControlsButton10'}->configure(-background=>$def_but_color);
	
	delete $GUI{'Exists'};
}

sub GetPanelIndex
{
	my $panel = shift;
	
	   if($panel eq 'General')		{ return 1; }
	elsif($panel eq 'Globals')		{ return 2; }
	elsif($panel eq 'Inventory')	{ return 3; }
	elsif($panel eq 'Journal')		{ return 4; }
	elsif($panel eq 'Player')		{ return 5; }
	elsif($panel eq 'NPCs')			{ return 6; }
	elsif($panel eq 'Classes')		{ return 7; }
	elsif($panel eq 'Feats')		{ return 8; }
	elsif($panel eq 'Powers')		{ return 9; }
	elsif($panel eq 'Equipment')	{ return 10; }
	elsif($panel =~ /NPCs(\d*)/)	{ return -2 - $1; }
	else							{ return -1; }
}

sub GetPanelXPadding
{
	my $panel = shift;
	
	   if($panel eq 'General')		{ return 50;	}
	elsif($panel eq 'Globals')		{ return 75;	}
	elsif($panel eq 'Inventory')	{ return 5;		}
	elsif($panel eq 'Journal')		{ return 5;		}
	elsif($panel eq 'Player')		{ return 15;	}
	elsif($panel eq 'NPCs')			{ return 100;	}
	elsif($panel eq 'Classes')		{ return 75;	}
	elsif($panel eq 'Feats')		{ return 50;	}
	elsif($panel eq 'Powers')		{ return 50;	}
	elsif($panel eq 'Equipment')	{ return 5;		}
	elsif($panel =~ /NPCs(\d*)/)	{ return 15;	}
#	else							{ return -1; }
}

sub GetPanelYPadding
{
	my $panel = shift;
	
	   if($panel eq 'General')		{ return 150;	}
	elsif($panel eq 'Globals')		{ return 100;	}
	elsif($panel eq 'Inventory')	{ return 5;	}
	elsif($panel eq 'Journal')		{ return 5;	}
	elsif($panel eq 'Player')		{ return 5;	}
	elsif($panel eq 'NPCs')			{ return 5;	}
	elsif($panel eq 'Classes')		{ return 150;	}
	elsif($panel eq 'Feats')		{ return 50;	}
	elsif($panel eq 'Powers')		{ return 5;	}
	elsif($panel eq 'Equipment')	{ return 5;	}
	elsif($panel =~ /NPCs(\d*)/)	{ return 5;	}
#	else							{ return -1; }
}

sub ShowPanel
{
	my $panel = shift;
	
#	my $panel_index = GetPanelIndex($panel);
#	
#	if($panel_index != -1)
#	{
#		if($panel_index > 0)
#		{
#			if($panel_index < 10)
#			{
#				$GUI{'ControlsButton0' . $panel_index}->configure(-background=>$act_but_color);
#			}
#			else
#			{
#				$GUI{'ControlsButton' . $panel_index}->configure(-background=>$act_but_color);
#			}
#			
#			foreach my $num (1 .. 9)
#			{
#				next if $num == $panel_index;
#				$GUI{'ControlsButton0' . $num}->configure(-background=>$def_but_color);
#			}
#			if($panel_index != 10)
#			{
#				$GUI{'ControlsButton10'}->configure(-background=>$def_but_color);
#			}
#			
#			foreach($GUI{ControlsList}->info('children', 'Control06'))
#			{
#				my $p = (split(/\#/, $_))[-1];
#				
#				$GUI{'ControlsButton06_' . $p}->configure(-background=>$def_but_color);
#			}
#		}
#		else
#		{
#			foreach my $num (1 .. 9)
#			{
#				$GUI{'ControlsButton0' . $num}->configure(-background=>$def_but_color);
#			}
#			$GUI{'ControlsButton10'}->configure(-background=>$def_but_color);
#
#			foreach($GUI{ControlsList}->info('children', 'Control06'))
#			{
#				my $p = (split(/\#/, $_))[-1];
#				
#				$GUI{'ControlsButton06_' . $p}->configure(-background=>$def_but_color);
#			}
#			
##			print "Checking for NPC panel " . (($panel_index + 2) * -1) . ". Math: " . ($panel_index + 2) . "\n";
#			if(defined($GUI{'ControlsButton06_' . (($panel_index + 2) * -1)}) == 1)
#			{
#				$GUI{'ControlsButton06_' . (($panel_index + 2) * -1)}->configure(-background=>$act_but_color);
#			}
#		}
#	}
#	
#	HidePanels();
#	
	if(defined($GUI{'Exists'}{$panel}) == 0) { CreatePanel($panel); }
	elsif($GUI{'Exists'}{$panel} == 0) { CreatePanel($panel); }
	else
	{
##		if($panel =~ /NPCs(\d)/) { KSE::GUI::NPC::UpdateNPCPanels(\$GUI{'Panels'}{'NPCs'}{'Widget1'}); }
#		if($panel eq 'NPCs') { KSE::GUI::NPC::UpdateNPCPanels($GUI{'Panels'}{'NPCs'}{'Widget1'}); }
##		elsif($panel eq 'Powers') { KSE::GUI::Classes::UpdateClassDropdown($GUI{'Panels'}{'Powers'}{'Widget2'}); }
	}
	
#	$GUI{'Panels'}{$panel}{'Frame'}->pack(-in=>$GUI{PanelFrame}, -fill=>'both', -expand=>1, -padx=>GetPanelXPadding($panel), -pady=>GetPanelYPadding($panel), -anchor=>'center');

	if($panel eq 'General')
	{
		$GUI{'Panels'}{'General'}{'Widget1'}->ChangeTarget('SaveGameName', 'AreaName', 'LastModule');
		$GUI{'Panels'}{'General'}{'Widget2'}->ChangeTarget('CheatUsed', 'SoloMode', 'CurrentParty');
		$GUI{'Panels'}{'General'}{'Widget3'}->ChangeTarget('TimePlayed', 'Credits', 'XP', 'Party XP');
	}
	$GUI{ControlsList}->raise($panel);
}

sub HidePanels
{
	foreach (keys %{$GUI{'Panels'}})
	{
		$GUI{'Panels'}{$_}{'Frame'}->packForget();
	}
}

sub RefreshPanels
{
	$GUI{'Panels'}{'Player'}{'Widget4'}->FillList();
	$GUI{'Panels'}{'Player'}{'Widget5'}->FillList();
	$GUI{'Panels'}{'Player'}{'Widget6'}->FillList();
	
	foreach my $type (keys %{$GUI{'Panels'}})
	{
		next if ($type =~ /NPC(\d*)/) == 0;
		
		$GUI{'Panels'}{$type}{'Widget4'}->FillList();
		$GUI{'Panels'}{$type}{'Widget5'}->FillList();
		$GUI{'Panels'}{$type}{'Widget6'}->FillList();
	}
}

sub GetPanelSelf
{
	my $target = shift;
	
	if($target eq 'Classes')
	{	return $GUI{'Panels'}{'Classes'}{'Widget1'};	}
	elsif($target eq 'Feats')
	{	return $GUI{'Panels'}{'Feats'}{'Widget3'};		}
	elsif($target eq 'Powers')
	{	return $GUI{'Panels'}{'Powers'}{'Widget3'};		}
	elsif($target eq 'Globals')
	{	return $GUI{'Panels'}{'Globals'}{'Widget1'};	}
	elsif($target eq 'Inventory')
	{	return $GUI{'Panels'}{'Inventory'}{'Widget1'};	}
	elsif($target eq 'Journal')
	{	return $GUI{'Panels'}{'Journal'}{'Widget1'};	}
	else
	{	return $GUI{'Panels'}{'Equipment'}{'Widget2'};	}		
}

#sub SetGUIData
#{
#	my ($section, $type, $entry, $data) = @_;
#	
#	if(defined($GUI{'Exists'}{$section}) == 0) { CreatePanel($section); }
#	elsif($GUI{'Exists'}{$section} == 0) { CreatePanel($section); }
#	else
#	{
##		if($panel =~ /NPCs(\d)/) { KSE::GUI::NPC::UpdateNPCPanels(\$GUI{'Panels'}{'NPCs'}{'Widget1'}); }
#		if($section eq 'NPCs') { KSE::GUI::NPC::UpdateNPCPanels(\$GUI{'Panels'}{'NPCs'}{'Widget1'}); }
#	}
#	
#	if($section eq 'General')
#	{
#		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'General'}{'Widget1'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'General'}{'Widget2'}->SetDataPiece($entry, $data); }
#		else									{ $GUI{'Panels'}{'General'}{'Widget3'}->SetDataPiece($entry, $data); }
#	}
##	elsif($section eq 'Globals')
##	{
##		$GUI{'Panels'}{'General'}{'Widget1'}->SetDataPiece($entry, $data); }
##	}
##	elsif($section eq 'Inventory')
##	{
##	
##	}
#	elsif($section eq 'Player')
#	{
#		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'Player'}{'Widget1'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'Player'}{'Widget2'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'SpinboxControls')		{ $GUI{'Panels'}{'Player'}{'Widget3'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'Appearance')			{ $GUI{'Panels'}{'Player'}{'Widget4'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'Portrait')				{ $GUI{'Panels'}{'Player'}{'Widget5'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'Soundset')				{ $GUI{'Panels'}{'Player'}{'Widget6'}->SetDataPiece($entry, $data); }
#	}
##	elsif($section eq 'Classes')
##	{
##	
##	}
#	elsif($section =~ /NPCs(\d*)/)
#	{
#		my $num = $1;
#		
#		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'NPC' . $num}{'Widget1'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'NPC' . $num}{'Widget2'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'SpinboxControls')	{ $GUI{'Panels'}{'NPC' . $num}{'Widget3'}->SetDataPiece($entry, $data); }
#		elsif($type eq 'Appearance')			{ $GUI{'Panels'}{'NPC' . $num}{'Widget4'}->GetDataPiece($entry, $data); }
#		elsif($type eq 'Portrait')				{ $GUI{'Panels'}{'NPC' . $num}{'Widget5'}->GetDataPiece($entry, $data); }
#		elsif($type eq 'Soundset')				{ $GUI{'Panels'}{'NPC' . $num}{'Widget6'}->GetDataPiece($entry, $data); }
#	}
##	elsif($section eq 'Feats')
##	{
##	
##	}
##	elsif($section eq 'Powers')
##	{
##	
##	}
##	else # Equipment
##	{
##	
##	}
#}

sub GetGUIData
{
	my ($section, $type, $entry) = @_;
	
	return undef if $GUI{'Exists'}{$section} == 0;
	
	if($section eq 'General')
	{
		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'General'}{'Widget1'}->GetDataPiece($entry); }
		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'General'}{'Widget2'}->GetDataPiece($entry); }
		else									{ $GUI{'Panels'}{'General'}{'Widget3'}->GetDataPiece($entry); }
	}
#	elsif($section eq 'Globals')
#	{
#		$GUI{'Panels'}{'General'}{'Widget1'}->SetDataPiece($entry, $data); }
#	}
#	elsif($section eq 'Inventory')
#	{
#	
#	}
	elsif($section eq 'Player')
	{
		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'Player'}{'Widget1'}->GetDataPiece($entry); }
		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'Player'}{'Widget2'}->GetDataPiece($entry); }
		elsif($type eq 'SpinboxControls')		{ $GUI{'Panels'}{'Player'}{'Widget3'}->GetDataPiece($entry); }
		elsif($type eq 'Appearance')			{ $GUI{'Panels'}{'Player'}{'Widget4'}->GetDataPiece($entry); }
		elsif($type eq 'Portrait')				{ $GUI{'Panels'}{'Player'}{'Widget5'}->GetDataPiece($entry); }
		elsif($type eq 'Soundset')				{ $GUI{'Panels'}{'Player'}{'Widget6'}->GetDataPiece($entry); }
	}
#	elsif($section eq 'Classes')
#	{
#	
#	}
	elsif($section =~ /NPCs(\d*)/)
	{
		my $num = $1;
		
		if($type eq 'TextEntryControls')		{ $GUI{'Panels'}{'NPCs' . $num}{'Widget1'}->GetDataPiece($entry); }
		elsif($type eq 'RadioOptionsControls')	{ $GUI{'Panels'}{'NPCs' . $num}{'Widget2'}->GetDataPiece($entry); }
		elsif($type eq 'SpinboxControls')		{ $GUI{'Panels'}{'NPCs' . $num}{'Widget3'}->GetDataPiece($entry); }
		elsif($type eq 'Appearance')			{ $GUI{'Panels'}{'NPCs' . $num}{'Widget4'}->GetDataPiece($entry); }
		elsif($type eq 'Portrait')				{ $GUI{'Panels'}{'NPCs' . $num}{'Widget5'}->GetDataPiece($entry); }
		elsif($type eq 'Soundset')				{ $GUI{'Panels'}{'NPCs' . $num}{'Widget6'}->GetDataPiece($entry); }

	}
#	elsif($section eq 'Feats')
#	{
#	
#	}
#	elsif($section eq 'Powers')
#	{
#	
#	}
#	else # Equipment
#	{
#	
#	}
}

# Save Commands
sub ToggleSavesFrame
{
	if($saves_shown == 1)
	{
		$GUI{SavesFrame}->pack(-side=>'left', -fill=>'both', -padx=>10, -pady=>5);
		$GUI{MasterFrame}->sashPlace(0, 537, 2);
		#$saves_shown = 1;
	}
	else
	{
		$GUI{SavesFrame}->packForget();
		$GUI{MasterFrame}->sashPlace(0, 277, 2);
		#$saves_shown = 0;
	}
}

sub ResetAllPanels
{
	foreach my $panel (keys %{$GUI{'Exists'}})
	{
#		$GUI{'Exists'}{$panel} = 0;
#		
#		$GUI{'Panels'}{$panel}{'Frame'}->destroy;
#		delete $GUI{'Panels'}{$panel};
	}
}

sub PopulatePaths
{
	$GUI{DirectoryFrame}{'Widget1'}->RepopulateList();
}

sub PopulateSaves
{
	my @saves = @_;
	
	ShowMainWindow();
	WithdrawMainWindow();
	ShowResourceLoadPopup();
	
	SetResourceStep('Finding saved games: ');
	$GUI{SavesList}->delete(0, 'end');
	DeleteAllPanels();
	my $i = 0;
	my $ii = scalar @saves;
	foreach (@saves)
	{
		$i++;
		$GUI{SavesList}->insert('end', $_);
		SetResourceStep("Finding saved games ($i of $ii): \n $_");
		SetResourceProgress(($i / $ii) * 100);
	}
	
	SetResourceStep('Refreshing data tables.');
	SetResourceProgress(0);
	KSE::Functions::Appearance::Assign2da();
	SetResourceProgress(12.5);
	KSE::Functions::Classes::Assign2da();
	SetResourceProgress(25);
	KSE::Functions::Portrait::Assign2da();
	SetResourceProgress(37.5);
	KSE::Functions::Soundset::Assign2da();
	SetResourceProgress(50);
	KSE::Functions::Feats::Assign2da();
	SetResourceProgress(62.5);
	KSE::Functions::Powers::Assign2da();
	SetResourceProgress(75);
	KSE::Functions::Equipment::ResetSlotItems();
	SetResourceProgress(87.5);
	KSE::Functions::NPC::ClearNPCHashes();
	SetResourceProgress(100);
	
	#CreatePanel("Inventory");
	foreach("General", "Globals", "Inventory", "Journal", "Stats", "Classes", "Feats", "Powers", "Equipment")
	#foreach("General", "Globals", "Inventory", "Journal", "Player", "NPCs", "Classes", "Feats", "Powers", "Equipment")
	##foreach("General", "Globals", "Journal", "Stats", "Classes", "Feats", "Powers", "Equipment")
	{
		print "Creating $_ panel.\n";
		if($_ ne 'Globals')	{ SetResourceStep('Creating ' . $_ . ' interface'); }
		else				{ SetResourceStep('Creating Global Variables interface.'); }
		
		CreatePanel($_);
	}
	
	CloseResourceLoadPopup();
	ShowMainWindow();
}

sub WithdrawMainWindow
{
	$GUI{mw}->withdraw;
}

sub ShowMainWindow
{
	$GUI{mw}->Popup();
}

sub GetTargetFrame
{
	return $GUI{TargetFrame};
}

sub ExitCheck
{
	my $check = KSE::Functions::Saves::SaveCheck();
	if($check > 0)
	{
		if($check == 2)
		{
			KSE::Functions::Saves::SaveSave();
		}
		
		KSE::Functions::Main::SavePathINI();
		File::Path::rmtree(KSE::Functions::Main::GetBaseDir() . '/temp');
		exit;
	}
}

sub GameLoadPopup
{
	$popupbox = $GUI{mw}->Toplevel(-title=>"Loading the savegame...");
	$popupbox->geometry("250x100");
	Set_Icon($popupbox);
	$popupbox->Label(-wraplength=>250, -text=>"The save " . $GUI{SavesList}->get($GUI{SavesIndex}) . " is loading.\n\nPlease wait...")->pack(-fill=>'x');
	
	$popupbox->withdraw;
	$popupbox->Popup(-overanchor=>'c');
	$popupbox->grab;
	$GUI{mw}->Busy;
}

sub GameSavePopup
{
	$popupbox = $GUI{mw}->Toplevel(-title=>"Saving the savegame...");
	$popupbox->geometry("250x100");
	Set_Icon($popupbox);
	$popupbox->Label(-wraplength=>250, -text=>"The save " . $GUI{SavesList}->get($GUI{SavesIndex}) . " is being saved and repacked.\n\nPlease wait...")->pack(-fill=>'x');
	
	$popupbox->withdraw;
	$popupbox->Popup(-overanchor=>'c');
	$popupbox->grab;
	$GUI{mw}->Busy;
}

sub GameClosePopup
{
	$GUI{mw}->Unbusy;
	$popupbox->grabRelease;
	$popupbox->destroy;
	$popupbox = undef;
}

sub ShowResourceLoadPopup
{
	$GUI{rl_popup} = $GUI{mw}->Toplevel(-title=>"Loading the savegame...");
	$GUI{rl_popup}->geometry("250x100");
	Set_Icon($GUI{rl_popup});
	$GUI{rl_popup}->Label(-wraplength=>250, -text=>'Processing KotOR' . KSE::Data::GetData('None', 'Game') . ' data and resources: ')->pack(-fill=>'x');
	$GUI{rl_popup}->Label(-wraplength=>250, -textvariable=>\$GUI{ProgressStep})->pack(-fill=>'x', -pady=>5);
	$GUI{rl_bar} = $GUI{rl_popup}->ProgressBar(-from=>0, -to=>100, -blocks=>100, -gap=>0, -height=>200, -width=>15, -colors=>[0, 'green'], -variable=>\$GUI{ProgressValue})->pack(-fill=>'x', -padx=>15, -pady=>5, -side=>'bottom');
	
	$GUI{rl_popup}->withdraw;
	$GUI{rl_popup}->Popup(-overanchor=>'c');
	$GUI{rl_popup}->grab;
	$GUI{mw}->Busy;
}

sub CloseResourceLoadPopup
{
	$GUI{rl_popup}->grabRelease;
	$GUI{rl_popup}->destroy;
	$GUI{mw}->Busy;
}

sub SetResourceStep
{
	my $value = shift;
	$GUI{ProgressStep} = $value;
	$GUI{rl_popup}->update;
}

sub SetResourceProgress
{
	my $value = shift;
	$GUI{ProgressValue} = $value;
	$GUI{rl_popup}->update;
	$GUI{rl_bar}->update;
}

return 1;