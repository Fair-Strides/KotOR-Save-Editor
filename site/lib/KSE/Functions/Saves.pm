#line 1 "KSE/Functions/Saves.pm"
package KSE::Functions::Saves;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA	= qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Data;

use KSE::Functions::Main;
use KSE::Functions::Equipment;

use KSE::GUI::Main;
use KSE::GUI::Directory;

use Bioware::ERF;
use Bioware::RIM;
use Bioware::GFF;

use Tk::Dialog;

use Unicode::String  qw(latin1);

my $mw = undef;

my %saves = ();
my $CurrentSave	= undef;
my $ExportPath	= undef;
my $use_saves_names = 1;

my $Savenfo_Obj		= Bioware::GFF->new();
my $GlobalVars_Obj	= Bioware::GFF->new();
my $PartyTable_Obj	= Bioware::GFF->new();
my $SavegameSav_Obj	= Bioware::ERF->new();
my $AreaSav_Obj		= Bioware::ERF->new();
my $pifo_obj		= Bioware::GFF->new();
my $Inventory_Obj	= Bioware::GFF->new();
my $ModuleIFO_Obj	= Bioware::GFF->new();
my @files_area		= ();
my @files_save		= ();

my %NPC = ();
$NPC{0}		= Bioware::GFF->new();
$NPC{1}		= Bioware::GFF->new();
$NPC{2}		= Bioware::GFF->new();
$NPC{3}		= Bioware::GFF->new();
$NPC{4}		= Bioware::GFF->new();
$NPC{5}		= Bioware::GFF->new();
$NPC{6}		= Bioware::GFF->new();
$NPC{7}		= Bioware::GFF->new();
$NPC{8}		= Bioware::GFF->new();
$NPC{9}		= Bioware::GFF->new();
$NPC{10}	= Bioware::GFF->new();
$NPC{11}	= Bioware::GFF->new();
$NPC{12}	= Bioware::GFF->new();

sub Set_Saves_Name
{
	$use_saves_names = shift;
}

sub Get_Saves_Name
{
	return $use_saves_names;
}

sub getUnicode
{
	my $text = shift;
	my $us = Unicode::String->new($text);
	$text = $us->latin1();
	chomp $text;
	return $text;
}

sub SetMW
{
	$mw = shift;
}

sub SaveCheck
{
	return 1 if defined($CurrentSave) == 0;
	
	my $value = $mw->Dialog(-title=>'Do you want to save your game?',
		-text=>"KSE is either trying to load a different game path\'s saved games or is attempting to shut down.\n\nDo you want to save your game?",
		-default_button=>'Yes',
		-buttons=>['Yes', 'No', 'Cancel'])->Show();
	
	if($value eq 'Yes')		{ $value = 2; }
	if($value eq 'No')		{ $value = 1; }
	if($value eq 'Cancel')	{ $value = 0; }
	
	return $value;
}

sub GetGame
{
	return $saves{'game'};
}

sub GetIsLoading
{
	return $saves{'Loading'};
}

sub GetCurrentSave
{
	return $CurrentSave;
}

sub GetInventoryRes
{
	return $Inventory_Obj;
}

sub GetSaveFile
{
	my ($file, $folder) = @_;
	
	if(defined($folder) == 0) { $folder = ''; }
	elsif(substr($output_path,-1) ne "/") { $folder .= '/'; }
	if(-e $ExportPath . $folder . $file) { return $ExportPath . $folder . $file; }

	return 0;
}

sub ResetAllSaves
{
	foreach (keys %Saves)
	{
		delete $saves{$_};
	}
}

sub GetAllSaves
{
	my ($game_path, $game_type, $use_cloud) = @_;

	$game_path =~ s/\\/\//g;
#	print "Game Path: $game_path\nGame Mode: $game_type\nCloud: $use_cloud\n\n";
	$saves{'game'} = $game_type;
	KSE::Data::SetData('None', $game_type, 'Game');
	
	if($game_type == 2 && $use_cloud == 1)
	{
		opendir SAVEDIR, "$game_path/cloudsaves";
		$saves{'path'} = "$game_path/cloudsaves";
	}
	else
	{
		opendir SAVEDIR, "$game_path/saves";
		$saves{'path'} = "$game_path/saves";
	}

	my @saves=grep { !(/\/\.+$/) && -d } map {"$game_path/saves/$_"} readdir(SAVEDIR);	#read all directories in saves dir
	close SAVEDIR;
	
	my $index = -1;
	foreach my $save_path (@saves)
	{
		$index++;
		if($use_saves_names == 0)
		{
			$saves[$index] = (split(/\//, $save_path))[-1];
		}
		else
		{
#			print "Save: " . $save_path . "/savenfo.res\n";
			my $answer = $Savenfo_Obj->read_gff_file($save_path . '/savenfo.res');
#			print "Answer: $answer.\n";
			my $save_name = $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('SAVEGAMENAME')]{Value};
			
			if($save_name eq "")
			{
				$saves[$index] = (split('\/', $save_path))[-1];
				print "Save Name is blank; using folder name (" . $saves[$index] . ") instead.\n";
			}
			elsif(($save_name =~ /^\W*$/) == 1)
			{
				$saves[$index] = (split('\/', $save_path))[-1];
				print "Save Name is empty spaces; using folder (" . $saves[$index] . ") name instead.\n";
			}
			elsif(defined($Savenfo_Obj->{Main}->fbl('AUTOSAVEPARAMS')) == 1)
			{
				$saves[$index] = (split(/\//, $save_path))[-1];
			}
			else
			{
				$saves[$index] = (split(/\//, $save_path))[-1] . ' (' . $save_name . ')';
			}
		}
	}
	
	return @saves;
}

sub UnloadSave
{
#	KSE::GUI::Main::DeleteAllPanels();
#	KSE::GUI::Main::RemoveNPCControls();
	KSE::GUI::Main::DisableControls();
	KSE::GUI::Main::AdjustTitle('Save', undef);
	KSE::GUI::Main::GetTargetFrame()->RemoveAllTargets();
	
	delete $saves{$CurrentSave};
	$CurrentSave = undef;
}

# Save
sub SaveSave
{
	return if defined($CurrentSave) == 0;
	
	my $SavePath = $saves{'path'} . '/' . $CurrentSave . '/';
	my $TestPath = KSE::Functions::Main::GetBaseDir() . '/Test/';
#	print "Module.ifo:\t" .		$ExportPath . 'area/module.ifo' . "\n";
#	print "AreaSav:\t" .		$ExportPath . 'sav/' . $saves{$CurrentSave}{'LASTMODULE'} . '.sav' . "\n";
#	print "SavegameSave:\t" .	$SavePath	. 'SAVEGAME.sav' . "\n";

	KSE::GUI::Main::GameSavePopup();
	print "1\tUpdating various data from various data-entry sections.\n";
#	SaveTextEntryControls();
###	SaveRadioOptionsControls();
#	SaveSpinButtonControls();
	
	print "2\tSaving Inventory.\n";
	KSE::Functions::Inventory::SaveInventoryToSave();

	print "3\tSaving Player Character data.\n";
	SavePlayerInfo();

	print "4\tSaving global variables.\n";
	KSE::Functions::Globals::SaveGlobals($GlobalVars_Obj, $SavePath . 'globalvars.res');

	print "5\tSaving NPCs: ";	
	# Save each party member
	foreach my $npc (0 .. 11)
	{
		print "_$npc";
		if(KSE::Functions::NPC::GetNPCExists($npc))
		{
			SaveNPCInfo($npc);
		}
	}

	print "\n6\tSaving TSL-specifics (Influence, Components, Chemicals).\n";
	# If this is a TSL save, let's save the Influence, Components, and Chemicals.
	if(GetGame() == 2)
	{
		print "7\n";
###		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_COMPONEN')]{Value} = $saves{$CurrentSave}{'Components'};
###		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_CHEMICAL')]{Value} = $saves{$CurrentSave}{'Chemicals'};
		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_COMPONEN')]{Value} = KSE::Data::GetData('None', 'Components');
		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_CHEMICAL')]{Value} = KSE::Data::GetData('None', 'Chemicals');
		
		print "8 ";
		my @influence = ();
		foreach my $pt_member (0 .. 11)
		{
			print "_$pt_member";
			#my $influence = $pt_member->{'Fields'}{'Value'};
			#print "NPC: $npc_index\tInfluence: $influence\n";
			my $struct = Bioware::GFF::Struct->new('ID'=>0);
			
###			$struct->createField('Type'=>FIELD_INT, 'Label'=>'PT_NPC_INFLUENCE', 'Value'=>$saves{$CurrentSave}{'NPC' . $pt_member}{'Influence'});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'PT_NPC_INFLUENCE', 'Value'=>KSE::Data::GetData('NPC' . $pt_member, 'Influence'));
			push (@influence, $struct);
		}
		
		$PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_INFLUENCE')]{Value} = \@influence;
	}
	
	print "\n9\tUpdating active party layout.\n";
	# Let's be sure to update the party members currently in the party.
	my $pt_members = [];
	foreach(1, 2)
	{
###		if(defined($saves{$CurrentSave}{'PT_MEMBER' . $_}) == 1)
		if((defined(KSE::Data::GetData('None', 'PT_MEMBER' . $_)) == 1) && (KSE::Data::GetData('None', 'PT_MEMBER' . $_) >= 0))
		{
			my $struct = Bioware::GFF::Struct->new('ID'=>0);
			my $is_leader = 0;
###			if($saves{$CurrentSave}{'Leader'} == $_) { $is_leader = 1; }
			if(KSE::Data::GetData('None', 'Leader') == $_) { $is_leader = 1; }
			
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'PT_IS_LEADER', 'Value'=>$is_leader);
###			$struct->createField('Type'=>FIELD_INT, 'Label'=>'PT_MEMBER_ID', 'Value'=>$saves{$CurrentSave}{'PT_MEMBER' . $_});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'PT_MEMBER_ID', 'Value'=>KSE::Data::GetData('None', 'PT_MEMBER' . $_));
			
			push(@$pt_members, $struct);
		}
		
		$PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_MEMBERS')]{Value} = $pt_members;
	}
	
	# Take care to update the portraits on the save menu.
	# Order is:
	# 0 - Player
	# 1 - Canderous = Struct1 in PT_Members in PARTYTABLE.res
	# 2 - Juhani	= Struct2 in PT_Members in PARTYTABLE.res
	#
	# In Save 1, Portrait0 - 0, Portrait1 - 1, Portrait2 - 2
	# In Save 2, Portrait0 - 1, Portrait1 - 2, Portrait2 - 0
	# In Save 3, Portrait0 - 2, Portrait1 - 0, Portrait2 - 1

	print "10\tUpdating save menu Portrait display.\n";
	my ($portrait0, $portrait1, $portrait2) = (undef, undef, undef);
####	print "Leader: " . $saves{$CurrentSave}{'Leader'} . "\n";
#	print "Leader: " . KSE::Data::GetData('None', 'Leader') . "\n";
###	if($saves{$CurrentSave}{'Leader'} == 0)
###	{
###		$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{'Player'}{'PortraitId'}, $saves{$CurrentSave}{'Player'}{'GoodEvil'});
###		
###		my $npc = '';
###		if(defined($saves{$CurrentSave}{'PT_MEMBER1'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER1'};
###			$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###		
###		if(defined($saves{$CurrentSave}{'PT_MEMBER2'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER2'};
###			$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###	}
###	elsif($saves{$CurrentSave}{'Leader'} == 1)
###	{
###		my $npc = '';
###		if(defined($saves{$CurrentSave}{'PT_MEMBER1'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER1'};
###			$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###		
###		if(defined($saves{$CurrentSave}{'PT_MEMBER2'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER2'};
###			$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###		
###		$portrait2 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{'Player'}{'PortraitId'}, $saves{$CurrentSave}{'Player'}{'GoodEvil'});
###	}
###	else
###	{
###		my $npc = '';
###		if(defined($saves{$CurrentSave}{'PT_MEMBER2'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER2'};
###			$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###		
###		$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{'Player'}{'PortraitId'}, $saves{$CurrentSave}{'Player'}{'GoodEvil'});
###		
###		if(defined($saves{$CurrentSave}{'PT_MEMBER1'}) == 1)
###		{
###			$npc = 'NPC' . $saves{$CurrentSave}{'PT_MEMBER1'};
###			$portrait2 = KSE::Functions::Portrait::GetPortraitByAlignment($saves{$CurrentSave}{$npc}{'PortraitId'}, $saves{$CurrentSave}{$npc}{'GoodEvil'});
###		}
###	}
	
	if(KSE::Data::GetData('None', 'Leader') == 0)
	{
		$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData('Player', 'PortraitId'), KSE::Data::GetData('Player', 'GoodEvil'));
		
		my $npc = '';
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER1')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER1');
			$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
		
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER2')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER2');
			$portrait2 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
	}
	elsif(KSE::Data::GetData('None', 'Leader') == 1)
	{
		my $npc = '';
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER1')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER1');
			$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
		
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER2')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER2');
			$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
		
		$portrait2 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData('Player', 'PortraitId'), KSE::Data::GetData('Player', 'GoodEvil'));
	}
	else
	{
		my $npc = '';
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER2')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER2');
			$portrait0 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
		
		$portrait1 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData('Player', 'PortraitId'), KSE::Data::GetData('Player', 'GoodEvil'));
		
		if(defined(KSE::Data::GetData('None', 'PT_MEMBER2')) == 1)
		{
			$npc = 'NPC' . KSE::Data::GetData('None', 'PT_MEMBER2');
			$portrait2 = KSE::Functions::Portrait::GetPortraitByAlignment(KSE::Data::GetData($npc, 'PortraitId'), KSE::Data::GetData($npc, 'GoodEvil'));
		}
	}
	
	my $p1_exists = $Savenfo_Obj->{Main}->fbl('PORTRAIT1');
	my $p2_exists = $Savenfo_Obj->{Main}->fbl('PORTRAIT2');
	
#	print "Portrait0: $portrait0\n";
#	print "Portrait1: $portrait1\n";
#	print "Portrait2: $portrait2\n";
	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('PORTRAIT0')]{Value} = $portrait0;
	if(defined($portrait1) == 1)
	{
		if(defined($p1_exists) == 1)
		{
			$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('PORTRAIT1')]{Value} = $portrait1;
		}
		else
		{
			$Savenfo_Obj->{Main}->createField('Type'=>FIELD_RESREF, 'Label'=>'PORTRAIT1', 'Value'=>$portrait1);
		}
	}
	if(defined($portrait2) == 1)
	{
		if(defined($p2_exists) == 1)
		{
			$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('PORTRAIT2')]{Value} = $portrait2;
		}
		else
		{
			$Savenfo_Obj->{Main}->createField('Type'=>FIELD_RESREF, 'Label'=>'PORTRAIT2', 'Value'=>$portrait2);
		}
	}
	
	print "11\tUpdating Partytable.res.\n";
	# Update the PARTYTABLE.res fields
###	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_CHEAT_USED')]{Value} = $saves{$CurrentSave}{'PT_CHEAT_USED'};
###	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_GOLD')]{Value} = $saves{$CurrentSave}{'CREDITS'};
###	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_NUM_MEMBERS')]{Value} = scalar @$pt_members;
###	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_PLAYEDSECONDS')]{Value} = $saves{$CurrentSave}{'TIMEPLAYED'};
###	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_SOLOMODE')]{Value} = $saves{$CurrentSave}{'SOLOMODE'};

	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_CHEAT_USED')]{Value} = KSE::Data::GetData('None', 'PT_CHEAT_USED');
	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_GOLD')]{Value} = KSE::Data::GetData('None', 'CREDITS');
	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_NUM_MEMBERS')]{Value} = scalar @$pt_members;
	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_PLAYEDSECONDS')]{Value} = KSE::Data::GetData('None', 'TIMEPLAYED');
	$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_SOLOMODE')]{Value} = KSE::Data::GetData('None', 'SOLOMODE');
	
	print "12\tUpdating and saving Savenfo.res.\n";
	# Update the Savenfo.res fields
###	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('SAVEGAMENAME')]{Value} = $saves{$CurrentSave}{'SAVEGAMENAME'};
###	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('CHEATUSED')]{Value} = $saves{$CurrentSave}{'CHEATUSED'};
###	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('TIMEPLAYED')]{Value} = $saves{$CurrentSave}{'TIMEPLAYED'};

	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('SAVEGAMENAME')]{Value} = KSE::Data::GetData('None', 'SAVEGAMENAME');
	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('CHEATUSED')]{Value} = KSE::Data::GetData('None', 'CHEATUSED');
	$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('TIMEPLAYED')]{Value} = KSE::Data::GetData('None', 'TIMEPLAYED');
	
	$Savenfo_Obj->write_gff_file($SavePath . 'savenfo.res');
	
	print "13\tSaving Partytable.res and Journal.\n";
	# Finally done updating stuff, so we can save files and wrap it up in a tidy bow.
	$PartyTable_Obj->write_gff_file($SavePath . 'partytable.res');
	KSE::Functions::Journal::SaveJRL($SavePath	. 'partytable.res');
	if($saves{$CurrentSave}{'use_pifo'} == 0)
	{
		print "Saving module.ifo file.\n";
		$ModuleIFO_Obj->write_gff_file($ExportPath . 'area/module.ifo');
	}

#	print "14\tPacking files into " . $saves{$CurrentSave}{'LASTMODULE'} . ".sav.\n";
	print "14\tPacking files into " . KSE::Data::GetData('None', 'LASTMODULE') . ".sav.\n";
	if($saves{$CurrentSave}{'use_sav'} == 1)
	{
####		print "Using " . $saves{$CurrentSave}{'LASTMODULE'} . ".sav.\n";
#		print "Using " . KSE::Data::GetData('None', LASTMODULE') . ".sav.\n";
		foreach my $file (@files_area)
		{
#			print "Adding $file to .sav file.\n";
			$AreaSav_Obj->import_resource($ExportPath . "area/$file", $file);
		}
		
###		$AreaSav_Obj->write_erf($ExportPath . "sav/" . $saves{$CurrentSave}{'LASTMODULE'} . '.sav');
		$AreaSav_Obj->write_erf($ExportPath . "sav/" . KSE::Data::GetData('None', 'LASTMODULE') . '.sav');
		
####		print "Making ERF " . $saves{$CurrentSave}{'LASTMODULE'} . '.sav' . " as a .sav type file.\nUsing directory: " . $ExportPath . 'area' . "\nand saving it at: " . $ExportPath . 'sav/' . $saves{$CurrentSave}{'LASTMODULE'} . '.sav' . "\n";
#		print "Making ERF " . KSE::Data::GetData('None', 'LASTMODULE') . '.sav' . " as a .sav type file.\nUsing directory: " . $ExportPath . 'area' . "\nand saving it at: " . $ExportPath . 'sav/' . KSE::Data::GetData('None', 'LASTMODULE') . '.sav' . "\n";
####	my ($result, $reason) = Bioware::ERF::make_new_from_folder($ExportPath . 'area', 'sav', $ExportPath . 'sav/' . $saves{$CurrentSave}{'LASTMODULE'} . '.sav');
#	my ($result, $reason) = Bioware::ERF::make_new_from_folder($ExportPath . 'area', 'sav', $ExportPath . 'sav/' . KSE::Data::GetData('None', 'LASTMODULE') . '.sav');
	}
	
	print "15\tPacking files into SAVEGAME.sav.\n";
	foreach my $file (@files_save)
	{
#		print "adding $file from " . $ExportPath . "sav/$file to SAVEGAME.sav\n";
		$SavegameSav_Obj->import_resource($ExportPath . "sav/$file", $file);
	}
	
	print "16\tSaving SAVEGAME.sav.\n";
	$SavegameSav_Obj->write_erf("$SavePath/SAVEGAME.sav");
	print "17\tDone!\n";
	KSE::GUI::Main::GameClosePopup();
}

sub SaveTextEntryControls
{
#	my $self = undef;
	# foreach my $entry ('Player', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	# {
		# if($entry ne 'Player')
		# {
			# $self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'TextEntryControls', 'FirstName');
			# if(defined($self) == 1 && $self ne '')
			# {
				# SetSaveData($self, 'NPC' . $entry, 'FirstName');
			# }
		# }
		# else
		# {
			# $self = KSE::GUI::Main::GetGUIData('Player', 'TextEntryControls', 'FirstName');
			# if(defined($self) == 1 && $self ne '')
			# {
				# SetSaveData($self, 'Player', 'FirstName');
			# }
		# }
	# }
#	
##	$self = KSE::GUI::Main::GetGUIData('General', 'TextEntryControls', 'SaveGameName');
##	if(defined($self) == 1 && $self ne '')
##	{
##		SetSaveData($self, 'SAVEGAMENAME');
##	}
}

sub SaveRadioOptionsControls
{
	my $self = undef;
	foreach my $entry ('Player', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	{
		if($entry ne 'Player')
		{
			$self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'RadioOptionsControls', 'Gender');
			if(defined($self) == 1 && $self ne '')
			{
				SetSaveData($self, 'NPC' . $entry, 'Gender');
			}
			
			$self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'RadioOptionsControls', 'Min1HP');
			if(defined($self) == 1 && $self ne '')
			{
				SetSaveData($self, 'NPC' . $entry, 'Min1HP');
			}
		}
		else
		{
			$self = KSE::GUI::Main::GetGUIData('Player', 'RadioOptionsControls', 'Gender');
			if(defined($self) == 1 && $self ne '')
			{
				SetSaveData($self, 'Player', 'Gender');
			}
			
			$self = KSE::GUI::Main::GetGUIData('Player', 'RadioOptionsControls', 'Min1HP');
			if(defined($self) == 1 && $self ne '')
			{
				SetSaveData($self, 'Player', 'Min1HP');
			}
		}
	}
	
	$self = KSE::GUI::Main::GetGUIData('General', 'RadioOptionsControls', 'CheatUsed');
	if(defined($self) == 1 && $self ne '')
	{
		SetSaveData($self, 'CHEATUSED');
	}
	
	$self = KSE::GUI::Main::GetGUIData('General', 'RadioOptionsControls', 'SoloMode');
	if(defined($self) == 1 && $self ne '')
	{
		SetSaveData($self, 'SOLOMODE');
	}
	
	$self = KSE::GUI::Main::GetGUIData('General', 'RadioOptionsControls', 'PT_MEMBER1');
	if(defined($self) == 1 && $self ne '')
	{
		SetSaveData($self, 'PT_MEMBER1');
	}
	
	$self = KSE::GUI::Main::GetGUIData('General', 'RadioOptionsControls', 'PT_MEMBER2');
	if(defined($self) == 1 && $self ne '')
	{
		SetSaveData($self, 'PT_MEMBER2');
	}
}

sub SaveSpinButtonControls
{
	my $self = undef;
	# foreach my $entry ('Player', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
	# {
		# if($entry ne 'Player')
		# {
			# foreach('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')
			# {
				# $self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'SpinboxControls', $_);
				# next if defined($self) == 0 || $self eq '';
				# #print "Self $_ $self.\n";
				#
				# SetSaveData($self, 'NPC' . $entry, 'Attributes', $_);
			# }
			#
			# foreach('HitPoints', 'MaxHitPoints', 'ForcePoints', 'MaxForcePoints')
			# {
				# $self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'SpinboxControls', $_);
				# next if defined($self) == 0 || $self eq '';
				#
				# SetSaveData($self, 'NPC' . $entry, $_);
			# }
			#
			# foreach('Computer Use', 'Demolitions', 'Stealth', 'Awareness', 'Persuade', 'Repair', 'Security', 'Treat Injury')
			# {
				# $self = KSE::GUI::Main::GetGUIData('NPCs' . $entry, 'SpinboxControls', $_);
				# next if defined($self) == 0 || $self eq '';
				#
				# SetSaveData($self, 'NPC' . $entry, 'Skills', $_);
			# }
		# }
		# else
		# {
			# foreach('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')
			# {
				# $self = KSE::GUI::Main::GetGUIData('Player', 'SpinButtonControls', $_);
				#
				# if(defined($self) == 1 && $self ne '')
				# {
					# SetSaveData($self, 'Player', 'Attributes', $_);
				# }
			# }
			#
			# foreach('HitPoints', 'MaxHitPoints', 'ForcePoints', 'MaxForcePoints')
			# {
				# $self = KSE::GUI::Main::GetGUIData('Player', 'SpinButtonControls', $_);
				# if(defined($self) == 1 && $self ne '')
				# {
					# SetSaveData($self, 'Player', $_);
				# }
			# }
			#
			# foreach('Computer Use', 'Demolitions', 'Stealth', 'Awareness', 'Persuade', 'Repair', 'Security', 'Treat Injury')
			# {
				# $self = KSE::GUI::Main::GetGUIData('Player', 'SpinButtonControls', $_);
				# if(defined($self) == 1 && $self ne '')
				# {
					# SetSaveData($self, 'Player', 'Skills', $_);
				# }
			# }
			#
			# $self = KSE::GUI::Main::GetGUIData('General', 'SpinButtonControls', 'XP');
			# if(defined($self) == 1 && $self ne '')
			# {
				# SetSaveData($self, 'Player', 'Experience');
			# }
		# }
	# }
	
##	$self = (KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Hours') * 3600) + (KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Minutes') * 60) + KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Seconds');
##	if(defined($self) == 1 && $self ne '')
##	{
##		SetSaveData($self, 'TIMEPLAYED');
##	}

#	$self = KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Credits');
#	if(defined($self) == 1 && $self ne '')
#	{
#		SetSaveData($self, 'CREDITS');
#	}
#	
#	$self = KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Party XP');
#	if(defined($self) == 1 && $self ne '')
#	{
#		SetSaveData($self, 'PARTYXP');
#	}
#	
#	if(GetGame() == 2)
#	{
#		KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Components');
#		if(defined($self) == 1 && $self ne '')
#		{
#			SetSaveData($self, 'Components');
#		}
#		
#		KSE::GUI::Main::GetGUIData('General', 'SpinboxControls', 'Chemicals');
#		if(defined($self) == 1 && $self ne '')
#		{
#			SetSaveData($self, 'Chemicals');
#		}
#	}
}

sub SetSaveData
{
	my ($data, @paths) = @_;
	
	my $path = $saves{$CurrentSave};
	
	if(scalar @paths > 1)
	{
		foreach my $p (@paths)
		{
			next if $p eq $paths[-1];
			
			$path = $path->{$p};
		}
		
		$path->{$paths[-1]} = $data;
	}
	else
	{
		$saves{$CurrentSave}{$paths[0]} = $data;
	}
}

sub GetSaveData
{
	my @paths = @_;
	
	my $path = $saves{$CurrentSave};
	
	my $l = 0;
#	if($paths[0] eq 'NPC7' && $paths[1] eq 'Equipment') { $l = 1; }
	if(scalar @paths > 1)
	{
		foreach my $p (@paths)
		{
#			print "p is $p: " if $l == 1;
			next if $p eq $paths[-1];
			
			if(defined($path->{$p}) == 1)
			{
#				print "proceeding\n" if $l == 1;
				$path = $path->{$p};
			}
			else
			{
#				print "nope!\n" if $l == 1;
				return undef;
			}
		}
#		print "returning path->[$paths[-1]]: " . $path->{$paths[-1]} . "\n" if $l == 1;
		return $path->{$paths[-1]};
	}
	else
	{
		return $saves{$CurrentSave}{$paths[0]};
	}
}

sub SaveNPCInfo
{
	my $NPC_num = shift;
	
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'} = getUnicode($saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'});
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'StringID'} = KSE::Functions::Main::GetLanguage();
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Gender')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Gender'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Str')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'STR'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Dex')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'DEX'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Con')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'CON'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Int')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'INT'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Wis')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'WIS'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Cha')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'CHA'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('HitPoints')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'HitPoints'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxHitPoints')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'MaxHitPoints'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ForcePoints')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'ForcePoints'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxForcePoints')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'MaxForcePoints'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Min1HP')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Min1HP'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Experience')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Experience'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('GoodEvil')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'GoodEvil'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Appearance_Type')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Appearance_Type'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('PortraitId')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'PortraitId'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SoundSetFile')]{'Value'} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'SoundSetFile'};
###
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'} = getUnicode(KSE::Data::GetData('NPC' . $NPC_num, 'FirstName'));
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'StringID'} = KSE::Functions::Main::GetLanguage();
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Gender')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Gender');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Str')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'STR');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Dex')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'DEX');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Con')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'CON');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Int')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'INT');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Wis')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'WIS');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Cha')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Attributes', 'CHA');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('HitPoints')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'HitPoints');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxHitPoints')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'MaxHitPoints');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ForcePoints')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'ForcePoints');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxForcePoints')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'MaxForcePoints');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Min1HP')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Min1HP');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Experience')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Experience');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('GoodEvil')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'GoodEvil');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Appearance_Type')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'Appearance_Type');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('PortraitId')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'PortraitId');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SoundSetFile')]{'Value'} = KSE::Data::GetData('NPC' . $NPC_num, 'SoundSetFile');

###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[0]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Computer Use'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[1]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Demolitons'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[2]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Stealth'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[3]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Awareness'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[4]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Persuade'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[5]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Repair'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[6]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Security'};
###	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[7]{Fields}{Value} = $saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Treat Injury'};
###
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[0]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Computer Use');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[1]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Demolitions');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[2]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Stealth');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[3]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Awareness');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[4]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Persuade');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[5]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Repair');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[6]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Security');
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[7]{Fields}{Value} = KSE::Data::GetData('NPC' . $NPC_num, 'Skills', 'Treat Injury');
	
	my $class_array = [];
#	$NPC{$NPC_num}->write_gff_file($ExportPath . 'sav/AVAILNPC' . $NPC_num . '.utc');
#	print "3 $NPC_num 0\n";
	foreach my $i (1, 2)
	{
#		$i++;
###		next if defined($saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Class'}) == 0;
###		next if $saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Class'} == -1;
		next if defined(KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Class')) == 0;
		next if KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Class') == -1;
		
		my $struct = Bioware::GFF::Struct->new('ID'=>2);
###		$struct->createField('Type'=>FIELD_INT, 'Label'=>'Class', 'Value'=>$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Class'});
		$struct->createField('Type'=>FIELD_INT, 'Label'=>'Class', 'Value'=>KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Class'));
#		print "3 $NPC_num 1\n";
###		$struct->createField('Type'=>FIELD_SHORT, 'Label'=>'ClassLevel', 'Value'=>$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Level'});
		$struct->createField('Type'=>FIELD_SHORT, 'Label'=>'ClassLevel', 'Value'=>KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Level'));
#		print "3 $NPC_num 2\n";
###		my @powers = @{$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Powers'}};
		my @powers = @{KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Powers')};
		
		if(scalar @powers > 0)
		{
			my $power_num = scalar @powers;
			my $power_array = [];
			
			my $power_i = -1;
			foreach my $power (@powers)
			{
				$power_i++;
				my $power_struct = Bioware::GFF::Struct->new('ID'=>3);
				$power_struct->createField('Type'=>FIELD_WORD, 'Label'=>'Spell', 'Value'=>$power);
				
				push(@$power_array, $power_struct);
			}
			
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'KnownList0', 'Value'=>$power_array);
		}
		
		push(@$class_array, $struct);
	}
#	print "3 $NPC_num 3\n";
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ClassList')]{Value} = $class_array;
#	$NPC{$NPC_num}->write_gff_file($ExportPath . 'sav/AVAILNPC' . $NPC_num . '.utc');
#	print "3 $NPC_num 4\n";

	my $feat_array = [];
###	foreach my $feat (@{$saves{$CurrentSave}{'NPC' . $NPC_num}{'Feats'}})
	foreach my $feat (@{KSE::Data::GetData('NPC' . $NPC_num, 'Feats')})
	{
		my $struct = Bioware::GFF::Struct->new('ID'=>1);
		$struct->createField('Type'=>FIELD_WORD, 'Label'=>'Feat', 'Value'=>$feat);
		
		push(@$feat_array, $struct);
	}
#	print "3 $NPC_num 5\n";
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FeatList')]{Value} = $feat_array;
	$NPC{$NPC_num}->write_gff_file($ExportPath . 'sav/AVAILNPC' . $NPC_num . '.utc');
	
#	print "3 $NPC_num 6\n";
	my $equip_structs = undef;
	foreach my $slot (KSE::Functions::Equipment::GetEquipmentSlots('NPC' . $NPC_num))
	{
		my $path	= KSE::Functions::Equipment::GetSlotItemPath('NPC' . $NPC_num, $slot);
		my $ID		= KSE::Functions::Equipment::GetSlotID($slot);
		my $struct 	= Bioware::GFF::Struct->new('ID'=>$ID);
		my $item	= Bioware::GFF->new();
###		my $resref	= $saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Resref'};
		my $resref	= KSE::Data::GetData('NPC' . $NPC_num, 'Equipment', $slot, 'Resref');
		
		my $main_struct = undef;
		if(defined($path) == 0 || $path eq '')
		{
			foreach my $n_struct (@{$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Equip_ItemList')]{Value}})
			{
				if($n_struct->{ID} == $ID)
				{
					$main_struct = $n_struct;
					last;
				}
			}
		}
#		print "$slot Path: $path\n";
#		print $saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'} . " is saving " . $saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} . " equipped in the $slot slot.\n";
		if($path eq 'BIF')
		{
			$BIF_obj->extract_resource("data\\templates.bif", $resref . ".uti", KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			$path = KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti';
		}

		if($resref ne 'saved')
		{
#			print "doing gff_file at $path\n";
			$item->read_gff_file($path);
			
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'AddCost', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('AddCost')]{'Value'});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'BaseItem', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('BaseItem')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Charges', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Charges')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'MaxCharges', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('MaxCharges')]{'Value'});
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Cost', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Cost')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'DescIdentified', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('DescIdentified')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('DescIdentified')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'Description', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('Description')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('Description')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Identified', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Identified')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'LocalizedName', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('LocalizedName')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('LocalizedName')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'ModelVariation', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('ModelVariation')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Plot', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Plot')]{'Value'});
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'PropertiesList', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('PropertiesList')]{'Value'});
			$struct->createField('Type'=>FIELD_WORD, 'Label'=>'StackSize', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('StackSize')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Stolen', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Stolen')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOSTRING, 'Label'=>'Tag', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Tag')]{'Value'});
			
			if($ID == 2)
			{
				$struct->createField('Type'=>FIELD_BYTE 'Label'=>'BodyVariation', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('BodyVariation')]{'Value'});
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'TextureVar', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('TextureVar')]{'Value'});
			}
			
			if(GetGame == 1)
			{
				$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Upgrades', 'Value'=>$item->{Main}{Fields}[$item->{Fields}->fbl('Upgrades')]{Value});
			}
			else
			{
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'UpgradeLevel', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeLevel')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot0', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot0')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot1', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot1')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot2', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot2')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot3', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot3')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot4', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot4')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot5', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot5')]{'Value'});
			}
		}
		else
		{
#			print "doing main_struct\n";
#			print "BaseItem: " . $main_struct->{Fields}[$main_struct->fbl('BaseItem')]{'Value'} . "\n";
			
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'AddCost', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('AddCost')]{'Value'});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'BaseItem', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('BaseItem')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Charges', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Charges')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'MaxCharges', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('MaxCharges')]{'Value'});
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Cost', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Cost')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'DescIdentified', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('DescIdentified')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('DescIdentified')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'Description', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('Description')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('Description')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Identified', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Identified')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'LocalizedName', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('LocalizedName')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('LocalizedName')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'ModelVariation', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('ModelVariation')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Plot', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Plot')]{'Value'});
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'PropertiesList', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('PropertiesList')]{'Value'});
			$struct->createField('Type'=>FIELD_WORD, 'Label'=>'StackSize', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('StackSize')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Stolen', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Stolen')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOSTRING, 'Label'=>'Tag', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Tag')]{'Value'});
			
			if($ID == 2)
			{
				$struct->createField('Type'=>FIELD_BYTE 'Label'=>'BodyVariation', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('BodyVariation')]{'Value'});
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'TextureVar', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('TextureVar')]{'Value'});
			}
			
			if(GetGame == 1)
			{
				$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Upgrades', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Upgrades')]{Value});
			}
			else
			{
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'UpgradeLevel', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeLevel')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot0', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot0')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot1', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot1')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot2', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot2')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot3', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot3')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot4', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot4')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot5', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot5')]{'Value'});
			}
		}
		push(@$equip_structs, $struct);
	}
	
#	print "3 $NPC_num 7\n";
	$NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Equip_ItemList')]{Value} = $equip_structs;

#	print "3 $NPC_num 8\n";
	$NPC{$NPC_num}->write_gff_file($ExportPath . 'sav/AVAILNPC' . $NPC_num . '.utc');
#	print "3 $NPC_num 9\n";
}

sub SavePlayerInfo
{
	# Change this to check for $saves{$CurrentSave}{'use_pifo'} and use the correct file.
	my $mod_playerlist = undef;
	
	if($saves{$CurrentSave}{'use_pifo'} == 1)
	{
		print "Using pifo.ifo for player info\n";
		$mod_playerlist = $pifo_obj->{Main}{Fields}{Value}->[0];
#		$mod_playerlist = $pifo_obj->{Main};
	}
	else
	{
		print "Using module.ifo for player info.\n";
		$mod_playerlist = $ModuleIFO_Obj->{Main}{Fields}[$ModuleIFO_Obj->{Main}->fbl('Mod_PlayerList')]{Value}[0];
	}

#	$mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'} = getUnicode($saves{$CurrentSave}{'Player'}{'FirstName'});
#	$mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'StringID'} = KSE::Functions::Main::GetLanguage();
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'} = getUnicode(KSE::Data::GetData('Player', 'FirstName'));
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'StringID'} = KSE::Functions::Main::GetLanguage();
	if($saves{'game'} == 2)
	{
#		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_PCNAME')]{Value} = $saves{$CurrentSave}{'Player'}{'FirstName'};
#		$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('PCNAME')]{Value} = $saves{$CurrentSave}{'Player'}{'FirstName'};
		$PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_PCNAME')]{Value} = getUnicode(KSE::Data::GetData('Player', 'FirstName'));
		$Savenfo_Obj->{Main}{Fields}[$Savenfo_Obj->{Main}->fbl('PCNAME')]{Value} = getUnicode(KSE::Data::GetData('Player', 'FirstName'));
	}
	
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Gender')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Gender'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Str')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'STR'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Dex')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'DEX'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Con')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'CON'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Int')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'INT'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Wis')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'WIS'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Cha')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Attributes'}{'CHA'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('HitPoints')]{'Value'} = $saves{$CurrentSave}{'Player'}{'HitPoints'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxHitPoints')]{'Value'} = $saves{$CurrentSave}{'Player'}{'MaxHitPoints'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('ForcePoints')]{'Value'} = $saves{$CurrentSave}{'Player'}{'ForcePoints'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxForcePoints')]{'Value'} = $saves{$CurrentSave}{'Player'}{'MaxForcePoints'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Min1HP')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Min1HP'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Experience')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Experience'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('GoodEvil')]{'Value'} = $saves{$CurrentSave}{'Player'}{'GoodEvil'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Appearance_Type')]{'Value'} = $saves{$CurrentSave}{'Player'}{'Appearance_Type'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('PortraitId')]{'Value'} = $saves{$CurrentSave}{'Player'}{'PortraitId'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SoundSetFile')]{'Value'} = $saves{$CurrentSave}{'Player'}{'SoundSetFile'};
###
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Gender')]{'Value'} = KSE::Data::GetData('Player', 'Gender');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Str')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'STR');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Dex')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'DEX');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Con')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'CON');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Int')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'INT');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Wis')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'WIS');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Cha')]{'Value'} = KSE::Data::GetData('Player', 'Attributes', 'CHA');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('HitPoints')]{'Value'} = KSE::Data::GetData('Player', 'HitPoints');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxHitPoints')]{'Value'} = KSE::Data::GetData('Player', 'MaxHitPoints');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('ForcePoints')]{'Value'} = KSE::Data::GetData('Player', 'ForcePoints');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxForcePoints')]{'Value'} = KSE::Data::GetData('Player', 'MaxForcePoints');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Min1HP')]{'Value'} = KSE::Data::GetData('Player', 'Min1HP');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Experience')]{'Value'} = KSE::Data::GetData('Player', 'Experience');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('GoodEvil')]{'Value'} = KSE::Data::GetData('Player', 'GoodEvil');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Appearance_Type')]{'Value'} = KSE::Data::GetData('Player', 'Appearance_Type');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('PortraitId')]{'Value'} = KSE::Data::GetData('Player', 'PortraitId');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SoundSetFile')]{'Value'} = KSE::Data::GetData('Player', 'SoundSetFile');

###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[0]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Computer Use'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[1]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Demolitons'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[2]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Stealth'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[3]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Awareness'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[4]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Persuade'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[5]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Repair'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[6]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Security'};
###	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[7]{Fields}{Value} = $saves{$CurrentSave}{'Player'}{'Skills'}{'Treat Injury'};
###
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[0]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Computer Use');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[1]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Demolitions');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[2]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Stealth');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[3]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Awareness');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[4]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Persuade');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[5]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Repair');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[6]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Security');
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[7]{Fields}{Value} = KSE::Data::GetData('Player', 'Skills', 'Treat Injury');
	
	# Save Classes
	my $class_array = [];
#	print "Class1: " . $saves{$CurrentSave}{'Player'}{'Class1'}{'Class'} . ".\n";
#	print "Class2: " . $saves{$CurrentSave}{'Player'}{'Class2'}{'Class'} . ".\n";
	foreach my $i (1, 2)
	{
#		$i++;
###		next if defined($saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}) == 0;
		next if defined(KSE::Data::GetData('Player', 'Class' . $i, 'Class')) == 0;
		
		my $struct = Bioware::GFF::Struct->new('ID'=>2);
#		$struct->createField('Type'=>FIELD_INT, 'Label'=>'Class', 'Value'=>$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'});
#		$struct->createField('Type'=>FIELD_SHORT, 'Label'=>'ClassLevel', 'Value'=>$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'});
		$struct->createField('Type'=>FIELD_INT, 'Label'=>'Class', 'Value'=>KSE::Data::GetData('Player', 'Class' . $i, 'Class'));
		$struct->createField('Type'=>FIELD_SHORT, 'Label'=>'ClassLevel', 'Value'=>KSE::Data::GetData('Player', 'Class' . $i, 'Level'));
		
		# Save Force Powers, if any
###		my @powers = @{$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'}};
		my @powers = @{KSE::Data::GetData('Player', 'Class' . $i, 'Powers')};
#		print "i: $i CurrentSave: $CurrentSave Array: @powers\nArray2: " . $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'} . "\nPowers:\t" . join(", ", @powers) . "\n";
		print "i: $i CurrentSave: $CurrentSave Array: @powers\nArray2: " . KSE::Data::GetData('Player', 'Class' . $i, 'Powers') . "\nPowers:\t" . join(", ", @powers) . "\n";
		
		if(scalar @powers > 0)
		{
			my $power_num = scalar @powers;
#			print "Saving powers: $i $power_num\n";
#			print "Array: " . join(", ", @powers) . "\n";
			
			my $power_array = [];
			
			my $power_i = -1;
			foreach my $power (@powers)
			{
				$power_i++;
#				print "Doing $power_i/$power_num\t$power\n";
				my $power_struct = Bioware::GFF::Struct->new('ID'=>3);
				$power_struct->createField('Type'=>FIELD_WORD, 'Label'=>'Spell', 'Value'=>$power);
				
				push(@$power_array, $power_struct);
			}
			
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'KnownList0', 'Value'=>$power_array);
		}
		
		push(@$class_array, $struct);
	}
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('ClassList')]{Value} = $class_array;

	# Save Feats
	my $feat_array = [];
###	foreach my $feat (@{$saves{$CurrentSave}{'Player'}{'Feats'}})
	foreach my $feat (@{KSE::Data::GetData('Player', 'Feats')})
	{
		my $struct = Bioware::GFF::Struct->new('ID'=>1);
		$struct->createField('Type'=>FIELD_WORD, 'Label'=>'Feat', 'Value'=>$feat);
		
		push(@$feat_array, $struct);
	}
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('FeatList')]{Value} = $feat_array;
	
	my $BIF_obj		= Bioware::BIF->new(KSE::Functions::Directory::GetGamePath());

	# Save Equipment
	my @equip_structs = [];
	foreach my $slot (KSE::Functions::Equipment::GetEquipmentSlots('Player'))
	{
		my $path	= KSE::Functions::Equipment::GetSlotItemPath('Player', $slot);
		my $ID		= KSE::Functions::Equipment::GetSlotID($slot);
		my $struct 	= Bioware::GFF::Struct->new('ID'=>$ID);
		my $item	= Bioware::GFF->new();
###		my $resref	= $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'};
		my $resref	= KSE::Data::GetData('Player', 'Equipment', $slot, 'Resref');
		
		my $main_struct = undef;
		if(defined($path) == 0 || $path eq '')
		{
#			if($saves{$CurrentSave}{'use_pifo'} == 1)
#			{
#				my $j = $pifo_obj->{Main}{Fields}{Value}->[0];
#				foreach $main_struct (@{$j->{Fields}[$j->fbl('Equip_ItemList')]{Value}})
#				{
#					if($main_struct->{ID} == $ID)
#					{
#						last;
#					}
#				}
#			}
#			else
#			{
#				my $mod_playerlist = $ModuleIFO_Obj->{Main}{Fields}[$ModuleIFO_Obj->{Main}->fbl('Mod_PlayerList')]{Value}[0];
				foreach my $n_struct (@{$mod_playerlist->{Fields}[$mod_playerlist->fbl('Equip_ItemList')]{Value}})
				{
					if($n_struct->{ID} == $ID)
					{
						$main_struct = $n_struct;
						last;
					}
				}
#			}
		}
		print "$slot Path: $path\n";
		
		if($path eq 'BIF')
		{
			$BIF_obj->extract_resource("data\\templates.bif", $resref . ".uti", KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			$path = KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti';
		}
#		if(defined($main_struct) == 0)
		if($resref ne 'saved')
		{
			print "doing gff_file at $path\n";
			$item->read_gff_file($path);
			
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'AddCost', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('AddCost')]{'Value'});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'BaseItem', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('BaseItem')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Charges', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Charges')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'MaxCharges', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('MaxCharges')]{'Value'});
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Cost', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Cost')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'DescIdentified', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('DescIdentified')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('DescIdentified')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'Description', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('Description')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('Description')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Identified', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Identified')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'LocalizedName', 'StringRef'=>$item->{Main}{Fields}[$item->{Main}->fbl('LocalizedName')]{'Value'}{'StringRef'}, 'Value'=>@{$item->{Main}{Fields}[$item->{Main}->fbl('LocalizedName')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'ModelVariation', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('ModelVariation')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Plot', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Plot')]{'Value'});
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'PropertiesList', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('PropertiesList')]{'Value'});
			$struct->createField('Type'=>FIELD_WORD, 'Label'=>'StackSize', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('StackSize')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Stolen', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Stolen')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOSTRING, 'Label'=>'Tag', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('Tag')]{'Value'});
			
			if($ID == 2)
			{
				$struct->createField('Type'=>FIELD_BYTE 'Label'=>'BodyVariation', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('BodyVariation')]{'Value'});
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'TextureVar', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('TextureVar')]{'Value'});
			}
			
			if(GetGame() == 1)
			{
				$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Upgrades', 'Value'=>$item->{Main}{Fields}[$item->{Fields}->fbl('Upgrades')]{Value});
			}
			else
			{
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'UpgradeLevel', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeLevel')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot0', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot0')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot1', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot1')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot2', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot2')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot3', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot3')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot4', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot4')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot5', 'Value'=>$item->{Main}{Fields}[$item->{Main}->fbl('UpgradeSlot5')]{'Value'});
			}
		}
		else
		{
			print "doing main_struct\n";
#			print "BaseItem: " . $main_struct->{Fields}[$main_struct->fbl('BaseItem')]{'Value'} . "\n";
			
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'AddCost', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('AddCost')]{'Value'});
			$struct->createField('Type'=>FIELD_INT, 'Label'=>'BaseItem', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('BaseItem')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Charges', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Charges')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'MaxCharges', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('MaxCharges')]{'Value'});
			$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Cost', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Cost')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'DescIdentified', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('DescIdentified')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('DescIdentified')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'Description', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('Description')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('Description')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Identified', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Identified')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>'LocalizedName', 'StringRef'=>$main_struct->{Fields}[$main_struct->fbl('LocalizedName')]{'Value'}{'StringRef'}, 'Value'=>@{$main_struct->{Fields}[$main_struct->fbl('LocalizedName')]{'Value'}{'Substrings'}});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'ModelVariation', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('ModelVariation')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Plot', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Plot')]{'Value'});
			$struct->createField('Type'=>FIELD_LIST, 'Label'=>'PropertiesList', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('PropertiesList')]{'Value'});
			$struct->createField('Type'=>FIELD_WORD, 'Label'=>'StackSize', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('StackSize')]{'Value'});
			$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'Stolen', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Stolen')]{'Value'});
			$struct->createField('Type'=>FIELD_CEXOSTRING, 'Label'=>'Tag', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Tag')]{'Value'});
			
			if($ID == 2)
			{
				$struct->createField('Type'=>FIELD_BYTE 'Label'=>'BodyVariation', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('BodyVariation')]{'Value'});
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'TextureVar', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('TextureVar')]{'Value'});
			}
			
			if(GetGame == 1)
			{
				$struct->createField('Type'=>FIELD_DWORD, 'Label'=>'Upgrades', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('Upgrades')]{Value});
			}
			else
			{
				$struct->createField('Type'=>FIELD_BYTE, 'Label'=>'UpgradeLevel', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeLevel')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot0', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot0')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot1', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot1')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot2', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot2')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot3', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot3')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot4', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot4')]{'Value'});
				$struct->createField('Type'=>FIELD_INT, 'Label'=>'UpgradeSlot5', 'Value'=>$main_struct->{Fields}[$main_struct->fbl('UpgradeSlot5')]{'Value'});
			}
		}
		push(@$equip_structs, $struct);
	}
	$mod_playerlist->{Fields}[$mod_playerlist->fbl('Equip_ItemList')]{Value} = $equip_structs;
	
	if($saves{$CurrentSave}{'use_pifo'} == 1)
	{
		$pifo_obj->write_gff_file($saves{'path'} . '/' . $CurrentSave . "/pifo.ifo");
#		$pifo_obj->write_gff_file($ExportPath . "/sav/pc.utc");
	}
}

# Load
sub GetIconName
{
	my ($id, $equiplist, $index) = @_;
	
	my $baseitem_2da = Bioware::TwoDA->new();
	$baseitem_2da->read2da(KSE::Functions::Directory::GetFile('baseitems.2da'));
	
#	my $baseitem = $equiplist->[$index]{Fields}[$equiplist->[$index]->fbl('BaseItem')]{Value};
	my $baseitem = $equiplist->{Fields}[$equiplist->fbl('BaseItem')]{Value};
	
#	my $modelvar = $equiplist->[$index]->fbl('ModelVariation');
	my $modelvar = $equiplist->fbl('ModelVariation');
	if(defined($modelvar) && ($equiplist->{Fields}[$modelvar]{Value} > 0))
	{
#		$modelvar = $equiplist->[$index]->{Fields}[$modelvar]{Value};
		$modelvar = $equiplist->{Fields}[$modelvar]{Value};
	}
	else
	{
#		$modelvar = $equiplist->[$index]{Fields}[$equiplist->[$index]->fbl('TextureVar')]{Value};
		$modelvar = $equiplist->{Fields}[$equiplist->fbl('TextureVar')]{Value};
	}
	
	if($modelvar < 10) { $modelvar = '00' . $modelvar; }
	elsif($modelvar < 100) { $modelvar = '0' . $modelvar; }
	
	my $icon = 'i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_$modelvar";
	
	return $icon;
}

sub LoadSave
{
	my $save = shift;

#	print "Save: $save\n";
	$save =~ s/ \(.*\)//g;
#	print "Save1: $save\n";

	$saves{$save}{'use_sav'} = 0;
	$saves{$save}{'use_pifo'} = 0;
	$saves{'Loading'} = 1;
	
	$CurrentSave = $save;
	KSE::GUI::Main::AdjustTitle('Save', $CurrentSave);
	KSE::GUI::Main::GameLoadPopup();
	
	KSE::GUI::Main::ResetAllPanels();
	
	$ExportPath	= KSE::Functions::Main::GetBaseDir() . '/temp/';
	my $save_path = $saves{'path'} . '/' . $save . '/';
	
#	File::Path::rmtree([$ExportPath]);
	mkdir($ExportPath);
	mkdir($ExportPath . 'sav');
	mkdir($ExportPath . 'area');
	
	$Savenfo_Obj->read_gff_file($save_path . 'savenfo.res');
	$Savenfo_Obj->write_gff_file($ExportPath . 'savenfo.res');
	$Savenfo_Obj->read_gff_file($ExportPath . 'savenfo.res');
	
	$GlobalVars_Obj->read_gff_file($save_path . 'globalvars.res');
	$GlobalVars_Obj->write_gff_file($ExportPath . 'globalvars.res');
	$GlobalVars_Obj->read_gff_file($ExportPath . 'globalvars.res');
	
	$PartyTable_Obj->read_gff_file($save_path . 'partytable.res');
	$PartyTable_Obj->write_gff_file($ExportPath . 'partytable.res');
	$PartyTable_Obj->read_gff_file($ExportPath . 'partytable.res');

	KSE::Functions::Globals::ReadGlobals($GlobalVars_Obj);
	KSE::GUI::Globals::RefreshEntries(KSE::GUI::Main::GetPanelSelf('Globals'));
	KSE::Functions::Journal::AssignJRL($saves{'game'}, $ExportPath . 'partytable.res');

	#read the SAVEGAME.SAV file
#	print "save path: $save_path" . 'savegame.sav' . "\n Result: ";
	my $c = $SavegameSav_Obj->read_erf($save_path . 'savegame.sav');
#	print "$c\n";

	@files_save = ();
	foreach($SavegameSav_Obj->getfiles())
	{
#		print "sav file: $_\n";
		push(@files_save, $_);
		$SavegameSav_Obj->export_resource($_, $ExportPath . 'sav/');
	}
	
	#read the SAVENFO.RES file
###	$saves{$save}{'LASTMODULE'}		= $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('LASTMODULE')]{Value};
###	$saves{$save}{'TIMEPLAYED'}		= $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('TIMEPLAYED')]{Value};
###	$saves{$save}{'SAVEGAMENAME'}	= $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('SAVEGAMENAME')]{Value};
###	$saves{$save}{'AREANAME'}		= join("\n", split(/\-/, $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('AREANAME')]{Value}));
###	$saves{$save}{'CHEATUSED'}		= $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('CHEATUSED')]{Value};
	KSE::Data::SetData('None', $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('LASTMODULE')]{Value}, 'LASTMODULE');
	KSE::Data::SetData('None', $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('TIMEPLAYED')]{Value}, 'TIMEPLAYED');
	KSE::Data::SetData('None', $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('SAVEGAMENAME')]{Value}, 'SAVEGAMENAME');
	KSE::Data::SetData('None', join("\n", split(/\-/, $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('AREANAME')]{Value})), 'AREANAME');
	KSE::Data::SetData('None', $Savenfo_Obj->{Main}->{Fields}->[$Savenfo_Obj->{Main}->fbl('CHEATUSED')]{Value}, 'CHEATUSED');
	
####	print "Last Module: " . $saves{$save}{'LASTMODULE'} . ".sav\n";
	print "Last Module: " . KSE::Data::GetData('None', 'LASTMODULE') . ".sav\n";
###	if(-e $ExportPath . 'sav/' . $saves{$save}{'LASTMODULE'} . '.sav')
	if(-e $ExportPath . 'sav/' . KSE::Data::GetData('None', 'LASTMODULE') . '.sav')
	{
		$saves{$save}{'use_sav'} = 1;
#		print "Opening Areasave " . $saves{$save}{'LASTMODULE'} . '.sav: ';
###		my $b = $AreaSav_Obj->read_erf($ExportPath . 'sav/' . $saves{$save}{'LASTMODULE'} . '.sav');
		my $b = $AreaSav_Obj->read_erf($ExportPath . 'sav/' . KSE::Data::GetData('None', 'LASTMODULE') . '.sav');
#		print "$b\n";
		
		@files_area = ();
		foreach($AreaSav_Obj->getfiles())
		{
#			print "area file: $_\n";
			push(@files_area, $_);
			$AreaSav_Obj->export_resource($_, $ExportPath . 'area/');
		}
	
		my $a = $ModuleIFO_Obj->read_gff_file($ExportPath . 'area/module.ifo');
		if($a == 0) { print "Failed to load the Module.ifo: " . $ExportPath . 'area/module.ifo' . "\n"; }
	}
	else
	{
		$saves{$save}{'use_sav'} = 0;
	}
	
	$Inventory_Obj->read_gff_file($ExportPath . 'sav/INVENTORY.res');
	KSE::Functions::Inventory::PopulateCountFromSave();
	KSE::GUI::Inventory::RefreshList(KSE::GUI::Main::GetPanelSelf('Inventory'));
	
	#read the PARTYTABLE.RES file
###	$saves{$save}{'CREDITS'}	= $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_GOLD')]{Value};
###	$saves{$save}{'PARTYXP'}	= $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_XP_POOL')]{Value};
###	$saves{$save}{'PT_CHEAT'}	= $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_CHEAT_USED')]{Value};
###	$saves{$save}{'SOLOMODE'}	= $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_SOLOMODE')]{Value};
	KSE::Data::SetData('None', $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_GOLD')]{Value}, 'CREDITS');
	KSE::Data::SetData('None', $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_XP_POOL')]{Value}, 'PARTYXP');
	KSE::Data::SetData('None', $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_CHEAT_USED')]{Value}, 'PT_CHEAT');
	KSE::Data::SetData('None', $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_SOLOMODE')]{Value}, 'SOLOMODE');
	
	my $pt_members_ref = $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_AVAIL_NPCS')]{Value};

	my $npc_index = -1;
	foreach my $pt_member (@$pt_members_ref)
	{
		$npc_index++;
		if($pt_member->{Fields}[$pt_member->fbl('PT_NPC_AVAIL')]{Value} == 1)
		{
			PopulateNPCInfo($npc_index);
			KSE::Functions::NPC::AddNPC($npc_index, $NPC{$npc_index});
		}
	}
	
	$pt_members_ref = $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_MEMBERS')]{Value};

###	$saves{$save}{'Leader'} = 0;
	KSE::Data::SetData('None', 0, 'Leader');
	
	$npc_index = 0;
###	$saves{$save}{'PT_MEMBER1'} = -1;
###	$saves{$save}{'PT_MEMBER2'} = -1;
	KSE::Data::SetData('None', -1, 'PT_MEMBER1');
	KSE::Data::SetData('None', -1, 'PT_MEMBER2');
	foreach my $pt_member (@$pt_members_ref)
	{
		$npc_index++;
###		$saves{$save}{'PT_MEMBER' . $npc_index} = $pt_member->{Fields}[$pt_member->fbl('PT_MEMBER_ID')]{Value};
		KSE::Data::SetData('None', $pt_member->{Fields}[$pt_member->fbl('PT_MEMBER_ID')]{Value}, 'PT_MEMBER' . $npc_index);
		if($pt_member->{Fields}[$pt_member->fbl('PT_IS_LEADER')]{Value} == 1)
###		{ $saves{$save}{'Leader'} = $npc_index; }
		{ KSE::Data::SetData('None', $npc_index, 'Leader'); }
		
####		print "PT_MEMBER$npc_index: " . $saves{$save}{'PT_MEMBER' . $npc_index} . "\n";
#		print "PT_MEMBER$npc_index: " . KSE::Data::GetData('None', 'PT_MEMBER' . $npc_index) . "\n";
	}
	
	if(GetGame() == 2)
	{
#		$saves{$save}{'Components'}	= $PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_COMPONEN')]{Value};
#		$saves{$save}{'Chemicals'}	= $PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_CHEMICAL')]{Value};
		KSE::Data::SetData('None', $PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_COMPONEN')]{Value}, 'Components');
		KSE::Data::SetData('None', $PartyTable_Obj->{Main}{Fields}[$PartyTable_Obj->{Main}->fbl('PT_ITEM_CHEMICAL')]{Value}, 'Chemicals');
		
		$pt_influence_ref = $PartyTable_Obj->{Main}->{Fields}->[$PartyTable_Obj->{Main}->fbl('PT_INFLUENCE')]{Value};
		
		$npc_index = -1;
		foreach my $pt_member (@$pt_influence_ref)
		{
			$npc_index++;
			#my $influence = $pt_member->{'Fields'}{'Value'};
			#print "NPC: $npc_index\tInfluence: $influence\n";
			
###			SetSaveData($pt_member->{'Fields'}{'Value'}, 'NPC' . $npc_index, 'Influence');
			KSE::Data::SetData('NPC' . $npc_index, $pt_member->{'Fields'}{'Value'}, 'Influence');
		}
	}
	
	if(-e $save_path . "pifo.ifo")
	{
		$saves{$save}{'use_pifo'} = 1;
		PopulatePlayerInfoFromFile();
	}
	else
	{
		$saves{$save}{'use_pifo'} = 0;
		PopulatePlayerInfo();
	}
	
	KSE::GUI::Main::GetTargetFrame()->ShowAllTargets();
	KSE::GUI::Main::ShowPanel('General');
	KSE::GUI::Main::GameClosePopup();
	$saves{'Loading'} = 0;
}

sub PopulateNPCInfo
{
	my $NPC_num = shift;
	$NPC{$NPC_num}->read_gff_file($ExportPath . 'sav/AVAILNPC' . $NPC_num . ".utc");
	
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName_StringRef'} = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'StringRef'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'} = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'StringRef'};
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'StringRef'}, 'FirstName_StringRef');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'StringRef'}, 'FirstName');
		
###	if($saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'} == -1)
	if(KSE::Data::GetData('NPC' . $NPC_num, 'FirstName') == -1)
	{
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'} = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'};
		KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'}, 'FirstName');
	}
	else
	{
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'});
		KSE::Data::SetData('NPC' . $NPC_num, Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), KSE::Data::GetData('NPC' . $NPC_num, 'FirstName')), 'FirstName');
	}

#	$saves{$CurrentSave}{'NPC' . $NPC_num}{'FirstName'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Gender'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Gender')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'STR'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Str')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'DEX'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Dex')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'CON'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Con')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'INT'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Int')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'WIS'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Wis')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Attributes'}{'CHA'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Cha')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'HitPoints'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('HitPoints')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'MaxHitPoints'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxHitPoints')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'ForcePoints'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'MaxForcePoints'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Min1HP'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Min1HP')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Experience'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Experience')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'GoodEvil'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('GoodEvil')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Appearance_Type'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Appearance_Type')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'PortraitId'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('PortraitId')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Race'}				= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Race')]{'Value'};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'SoundSetFile'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SoundSetFile')]{'Value'};
###	
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Gender')]{'Value'}, 'Gender');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Str')]{'Value'}, 'Attributes', 'STR');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Dex')]{'Value'}, 'Attributes', 'DEX');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Con')]{'Value'}, 'Attributes', 'CON');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Int')]{'Value'}, 'Attributes', 'INT');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Wis')]{'Value'}, 'Attributes', 'WIS');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Cha')]{'Value'}, 'Attributes', 'CHA');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('HitPoints')]{'Value'}, 'HitPoints');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxHitPoints')]{'Value'}, 'MaxHitPoints');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ForcePoints')]{'Value'}, 'ForcePoints');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('MaxForcePoints')]{'Value'}, 'MaxForcePoints');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Min1HP')]{'Value'}, 'Min1HP');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Experience')]{'Value'}, 'Experience');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('GoodEvil')]{'Value'}, 'GoodEvil');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Appearance_Type')]{'Value'}, 'Appearance_Type');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('PortraitId')]{'Value'}, 'PortraitId');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Race')]{'Value'}, 'Race');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SoundSetFile')]{'Value'}, 'SoundSetFile');
###
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Computer Use'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[0]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Demolitions'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[1]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Stealth'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[2]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Awareness'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[3]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Persuade'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[4]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Repair'}			= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[5]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Security'}		= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[6]{Fields}{Value};
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Skills'}{'Treat Injury'}	= $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[7]{Fields}{Value};
###
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[0]{Fields}{Value}, 'Skills', 'Computer Use');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[1]{Fields}{Value}, 'Skills', 'Demolitions');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[2]{Fields}{Value}, 'Skills', 'Stealth');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[3]{Fields}{Value}, 'Skills', 'Awareness');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[4]{Fields}{Value}, 'Skills', 'Persuade');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[5]{Fields}{Value}, 'Skills', 'Repair');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[6]{Fields}{Value}, 'Skills', 'Security');
	KSE::Data::SetData('NPC' . $NPC_num, $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('SkillList')]{'Value'}[7]{Fields}{Value}, 'Skills', 'Treat Injury');
	
	my $class_struct = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('ClassList')]{Value};
	
	$i = 0;
	foreach my $struct (@$class_struct)
	{
		$i++;
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Class'}	= $struct->{Fields}[$struct->fbl('Class')]{Value};
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Level'}	= $struct->{Fields}[$struct->fbl('ClassLevel')]{Value};
		KSE::Data::SetData('NPC' . $NPC_num, $struct->{Fields}[$struct->fbl('Class')]{Value}, 'Class' . $i, 'Class');
		KSE::Data::SetData('NPC' . $NPC_num, $struct->{Fields}[$struct->fbl('ClassLevel')]{Value}, 'Class' . $i, 'Level');
		
###		KSE::Functions::Classes::SetClassInfo('NPC' . $NPC_num, $i, $saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Class'}, $saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Level'});
		KSE::Functions::Classes::SetClassInfo('NPC' . $NPC_num, $i, KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Class'), KSE::Data::GetData('NPC' . $NPC_num, 'Class' . $i, 'Level'));
		
		my $power_struct = $struct->{Fields}[$struct->fbl('KnownList0')]{Value};
		my @powers = ();
		
		if(defined($power_struct))
		{
			foreach $power (@$power_struct)
			{
				push(@powers, $power->{Fields}{Value});
			}
		}
		
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Class' . $i}{'Powers'} = \@powers;
		KSE::Data::SetData('NPC' . $NPC_num, \@powers, 'Class' . $i, 'Powers');
	}
	
	my $feat_struct = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('FeatList')]{Value};
	my @feats = ();
	
	foreach my $struct (@$feat_struct)
	{
		push(@feats, $struct->{Fields}{Value});
	}
###	$saves{$CurrentSave}{'NPC' . $NPC_num}{'Feats'} = \@feats;
	KSE::Data::SetData('NPC' . $NPC_num, \@feats, 'Feats');
	
	my $mod_playerequiplist = $NPC{$NPC_num}->{Main}{Fields}[$NPC{$NPC_num}->{Main}->fbl('Equip_ItemList')]{Value};

	foreach my $slot ('Head', 'Armor', 'Gloves', 'RWeapon', 'LWeapon', 'LArm', 'RArm', 'Implant', 'Belt', 'RWeapon2', 'LWeapon2')
	{
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Resref'} = undef;
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Icon'} = undef;
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = undef;
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name_StringRef'} = undef;

		KSE::Data::SetData('NPC' . $NPC_num, undef, 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('NPC' . $NPC_num, undef, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('NPC' . $NPC_num, undef, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('NPC' . $NPC_num, undef, 'Equipment', $slot, 'Name_StringRef');
	}
	
	my $in = 0;
	foreach my $struct (@$mod_playerequiplist)
	{
		my $id = $struct->{ID};
		my $icon = GetIconName($id, $struct, $in);
		my $slot = KSE::Functions::Equipment::GetSlotName($id);
		
#		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Resref'} = $struct->{Fields}[$struct->fbl('Tag')]{Value};
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Resref'} = 'saved';
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Icon'} = $icon;
#		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name_StringRef'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};

		KSE::Data::SetData('NPC' . $NPC_num, 'saved', 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('NPC' . $NPC_num, $icon, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('NPC' . $NPC_num, $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('NPC' . $NPC_num, $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name_StringRef');
		
###		if($saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} == -1)
		if(KSE::Data::GetData('NPC' . $NPC_num, 'Equipment', $slot, 'Name') == -1)
		{
#			$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
###			$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			KSE::Data::SetData('NPC' . $NPC_num, $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'}, 'Equipment', $slot, 'Name');
		}
		else
		{
###			$saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'});
			KSE::Data::SetData('NPC' . $NPC_num, Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'NPC' . $NPC_num}{'Equipment'}{$slot}{'Name'}), 'Equipment', $slot, 'Name');
		}
		
#		if($NPC_num == 7) { print "Mira has " . $saves{$CurrentSave}{'NPC7'}{'Equipment'}{$slot}{'Name'} . " equipped in the $slot slot.\n"; }
		$in++;
	}
	
	KSE::GUI::Main::GetTargetFrame()->AddTarget('NPC' . $NPC_num, KSE::Functions::Portrait::GetPortraitFileByAlignment(KSE::Data::GetData('NPC' . $NPC_num, 'PortraitId'), KSE::Data::GetData('NPC' . $NPC_num, 'GoodEvil')), KSE::Data::GetData('NPC' . $NPC_num, 'FirstName'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $NPC_num, 'Class1', 'Class')) . ' ' . KSE::Data::GetData('NPC' . $NPC_num, 'Class1', 'Level'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $NPC_num, 'Class2', 'Class')) . ' ' . KSE::Data::GetData('NPC' . $NPC_num, 'Class2', 'Level'), KSE::Data::GetData('NPC' . $NPC_num, 'HitPoints') . '/' . KSE::Data::GetData('NPC' . $NPC_num, 'MaxHitPoints') . ' HP', KSE::Data::GetData('NPC' . $NPC_num, 'ForcePoints') . '/' . KSE::Data::GetData('NPC' . $NPC_num, 'MaxForcePoints') . ' FP');
}

sub PopulatePlayerInfoFromFile
{
	$pifo_obj->read_gff_file($saves{'path'} . '/' . $CurrentSave . "/pifo.ifo");
#	$pifo_obj->read_gff_file($ExportPath . "/sav/pc.utc");
	my $j = $pifo_obj->{Main}{Fields}{Value}->[0];
#	my $j = $pifo_obj->{Main};
	
###	$saves{$CurrentSave}{'Player'}{'FirstName'} = $j->{Fields}[$j->fbl('FirstName')]{Value}{'StringRef'};
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('FirstName')]{Value}{'StringRef'}, 'FirstName');
###	print "First name: " . $saves{$CurrentSave}{'Player'}{'FirstName'} . "\n";
	print "First name: " . KSE::Data::GetData('Player', 'FirstName') . "\n";
	
###	if($saves{$CurrentSave}{'Player'}{'FirstName'} == -1)
	if(KSE::Data::GetData('Player', 'FirstName') == -1)
	{
#			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
###		$saves{$CurrentSave}{'Player'}{'FirstName'} = $j->{Fields}[$j->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'};
		KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'}, 'FirstName');
	}
	else
	{
###		$saves{$CurrentSave}{'Player'}{'FirstName'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'FirstName'});
		KSE::Data::SetData('Player', Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'FirstName'}), 'FirstName');
	}

#	$saves{$CurrentSave}{'Player'}{'FirstName'}			= $j->{Fields}[$j->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Gender'}			= $j->{Fields}[$j->fbl('Gender')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'STR'}	= $j->{Fields}[$j->fbl('Str')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'DEX'}	= $j->{Fields}[$j->fbl('Dex')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'CON'}	= $j->{Fields}[$j->fbl('Con')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'INT'}	= $j->{Fields}[$j->fbl('Int')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'WIS'}	= $j->{Fields}[$j->fbl('Wis')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'CHA'}	= $j->{Fields}[$j->fbl('Cha')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'HitPoints'}			= $j->{Fields}[$j->fbl('HitPoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'MaxHitPoints'}		= $j->{Fields}[$j->fbl('MaxHitPoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'ForcePoints'}		= $j->{Fields}[$j->fbl('ForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'MaxForcePoints'}	= $j->{Fields}[$j->fbl('MaxForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Min1HP'}			= $j->{Fields}[$j->fbl('Min1HP')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Experience'}		= $j->{Fields}[$j->fbl('Experience')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'GoodEvil'}			= $j->{Fields}[$j->fbl('GoodEvil')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Appearance_Type'}	= $j->{Fields}[$j->fbl('Appearance_Type')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'PortraitId'}		= $j->{Fields}[$j->fbl('PortraitId')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Race'}				= $j->{Fields}[$j->fbl('Race')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'SoundSetFile'}		= $j->{Fields}[$j->fbl('SoundSetFile')]{'Value'};
###
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Gender')]{'Value'}, 'Gender');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Str')]{'Value'}, 'Attributes', 'STR');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Dex')]{'Value'}, 'Attributes', 'DEX');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Con')]{'Value'}, 'Attributes', 'CON');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Int')]{'Value'}, 'Attributes', 'INT');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Wis')]{'Value'}, 'Attributes', 'WIS');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Cha')]{'Value'}, 'Attributes', 'CHA');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('HitPoints')]{'Value'}, 'HitPoints');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('MaxHitPoints')]{'Value'}, 'MaxHitPoints');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('ForcePoints')]{'Value'}, 'ForcePoints');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('MaxForcePoints')]{'Value'}, 'MaxForcePoints');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Min1HP')]{'Value'}, 'Min1HP');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Experience')]{'Value'}, 'Experience');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('GoodEvil')]{'Value'}, 'GoodEvil');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Appearance_Type')]{'Value'}, 'Appearance_Type');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('PortraitId')]{'Value'}, 'PortraitId');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('Race')]{'Value'}, 'Race');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SoundSetFile')]{'Value'}, 'SoundSetFile');
	
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Computer Use'}	= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[0]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Demolitions'}		= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[1]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Stealth'}			= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[2]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Awareness'}		= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[3]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Persuade'}		= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[4]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Repair'}			= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[5]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Security'}		= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[6]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Treat Injury'}	= $j->{Fields}[$j->fbl('SkillList')]{'Value'}[7]{Fields}{Value};
###
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[0]{Fields}{Value}, 'Skills', 'Computer Use');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[1]{Fields}{Value}, 'Skills', 'Demolitions');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[2]{Fields}{Value}, 'Skills', 'Stealth');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[3]{Fields}{Value}, 'Skills', 'Awareness');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[4]{Fields}{Value}, 'Skills', 'Persuade');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[5]{Fields}{Value}, 'Skills', 'Repair');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[6]{Fields}{Value}, 'Skills', 'Security');
	KSE::Data::SetData('Player', $j->{Fields}[$j->fbl('SkillList')]{'Value'}[7]{Fields}{Value}, 'Skills', 'Treat Injury');
	
	my $class_struct = $j->{Fields}[$j->fbl('ClassList')]{Value};
	
	$i = 0;
	foreach my $struct (@$class_struct)
	{
		$i++;
		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}	= $struct->{Fields}[$struct->fbl('Class')]{Value};
		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'}	= $struct->{Fields}[$struct->fbl('ClassLevel')]{Value};

		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('Class')]{Value}, 'Class' . $i, 'Class');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('ClassLevel')]{Value}, 'Class' . $i, 'Level');
		
###		KSE::Functions::Classes::SetClassInfo('Player', $i, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'});
		KSE::Functions::Classes::SetClassInfo('Player', $i, KSE::Data::GetData('Player', 'Class' . $i, 'Class'), KSE::Data::GetData('Player', 'Class' . $i, 'Level'));
		
		my $power_struct = $struct->{Fields}[$struct->fbl('KnownList0')]{Value};
		my @powers = ();
		
		if(defined($power_struct))
		{
			foreach $power (@$power_struct)
			{
				push(@powers, $power->{Fields}{Value});
			}
		}
		
###		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'} = \@powers;
		KSE::Data::SetData('Player', \@powers, 'Class' . $i, 'Powers')
	}
	
	my $feat_struct = $j->{Fields}[$j->fbl('FeatList')]{Value};
	my @feats = ();
	
	foreach my $struct (@$feat_struct)
	{
###		push(@{$saves{$CurrentSave}{'Player'}{'Feats'}}, $struct->{Fields}{Value});
		push(@feats, $struct->{Fields}{Value});
	}
	
	KSE::Data::SetData('Player', \@feats, 'Feats');
	my $mod_playerequiplist = $j->{Fields}[$j->fbl('Equip_ItemList')]{Value};

	foreach my $slot ('Head', 'Armor', 'Gloves', 'RWeapon', 'LWeapon', 'LArm', 'RArm', 'Implant', 'Belt', 'RWeapon2', 'LWeapon2')
	{
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = undef;
		
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Name_StringRef');
	}
	
	my $in = 0;
	foreach my $struct (@$mod_playerequiplist)
	{
		my $id = $struct->{ID};
		my $icon = GetIconName($id, $struct, $in);
		my $slot = KSE::Functions::Equipment::GetSlotName($id);
		
		
#		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('Tag')]{Value};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = $struct->{Fields}[$struct->fbl('Tag')]{Value};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = $icon;
#		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};

		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('Tag')]{Value}, 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('Player', $icon, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name_StringRef');
		
		if(KSE::Data::GetData('Player', 'Equipment', $slot, 'Name') == -1)
		{
#			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
###			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'}, 'Equipment', $slot, 'Name');
		}
		else
		{
###			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'});
			KSE::Data::SetData('Player', Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'}), 'Equipment', $slot, 'Name');
		}
		
		$in++;
	}
	
	KSE::GUI::Main::GetTargetFrame()->AddTarget('Player', KSE::Functions::Portrait::GetPortraitFileByAlignment(KSE::Data::GetData('Player', 'PortraitId'), KSE::Data::GetData('Player', 'GoodEvil')), KSE::Data::GetData('Player', 'FirstName'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('Player', 'Class1', 'Class')) . ' ' . KSE::Data::GetData('Player', 'Class1', 'Level'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('Player', 'Class2', 'Class')) . ' ' . KSE::Data::GetData('Player', 'Class2', 'Level'), KSE::Data::GetData('Player', 'HitPoints') . '/' . KSE::Data::GetData('Player', 'MaxHitPoints') . ' HP', KSE::Data::GetData('Player', 'ForcePoints') . '/' . KSE::Data::GetData('Player', 'MaxForcePoints') . ' FP');
}

sub PopulatePlayerInfo
{
	my $mod_playerlist=$ModuleIFO_Obj->{Main}{Fields}[$ModuleIFO_Obj->{Main}->fbl('Mod_PlayerList')]{Value}[0];
	
###	$saves{$CurrentSave}{'Player'}{'FirstName'} = $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{Value}{'StringRef'};
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{Value}{'StringRef'}, 'FirstName');
###	print "First name: " . $saves{$CurrentSave}{'Player'}{'FirstName'} . "\n";
	print "First name: " . KSE::Data::GetData('Player', 'FirstName') . "\n";
	
###	if($saves{$CurrentSave}{'Player'}{'FirstName'} == -1)
	if(KSE::Data::GetData('Player', 'FirstName') == -1)
	{
#			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
###		$saves{$CurrentSave}{'Player'}{'FirstName'} = $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'};
		KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{Value}{'Substrings'}[0]{'Value'}, 'FirstName');
	}
	else
	{
###		$saves{$CurrentSave}{'Player'}{'FirstName'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'FirstName'});
		KSE::Data::SetData('Player', Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'FirstName'}), 'FirstName');
	}

#	$saves{$CurrentSave}{'Player'}{'FirstName'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Gender'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Gender')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'STR'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Str')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'DEX'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Dex')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'CON'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Con')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'INT'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Int')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'WIS'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Wis')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Attributes'}{'CHA'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Cha')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'HitPoints'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('HitPoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'MaxHitPoints'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxHitPoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'ForcePoints'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('ForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'MaxForcePoints'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxForcePoints')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Min1HP'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Min1HP')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Experience'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Experience')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'GoodEvil'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('GoodEvil')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Appearance_Type'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Appearance_Type')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'PortraitId'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('PortraitId')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'Race'}				= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Race')]{'Value'};
###	$saves{$CurrentSave}{'Player'}{'SoundSetFile'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SoundSetFile')]{'Value'};
###
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Gender')]{'Value'}, 'Gender');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Str')]{'Value'}, 'Attributes', 'STR');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Dex')]{'Value'}, 'Attributes', 'DEX');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Con')]{'Value'}, 'Attributes', 'CON');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Int')]{'Value'}, 'Attributes', 'INT');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Wis')]{'Value'}, 'Attributes', 'WIS');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Cha')]{'Value'}, 'Attributes', 'CHA');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('HitPoints')]{'Value'}, 'HitPoints');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxHitPoints')]{'Value'}, 'MaxHitPoints');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('ForcePoints')]{'Value'}, 'ForcePoints');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxForcePoints')]{'Value'}, 'MaxForcePoints');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Min1HP')]{'Value'}, 'Min1HP');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Experience')]{'Value'}, 'Experience');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('GoodEvil')]{'Value'}, 'GoodEvil');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Appearance_Type')]{'Value'}, 'Appearance_Type');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('PortraitId')]{'Value'}, 'PortraitId');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('Race')]{'Value'}, 'Race');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SoundSetFile')]{'Value'}, 'SoundSetFile');
	
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Computer Use'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[0]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Demolitions'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[1]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Stealth'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[2]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Awareness'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[3]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Persuade'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[4]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Repair'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[5]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Security'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[6]{Fields}{Value};
###	$saves{$CurrentSave}{'Player'}{'Skills'}{'Treat Injury'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[7]{Fields}{Value};
###
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[0]{Fields}{Value}, 'Skills', 'Computer Use');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[1]{Fields}{Value}, 'Skills', 'Demolitions');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[2]{Fields}{Value}, 'Skills', 'Stealth');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[3]{Fields}{Value}, 'Skills', 'Awareness');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[4]{Fields}{Value}, 'Skills', 'Persuade');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[5]{Fields}{Value}, 'Skills', 'Repair');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[6]{Fields}{Value}, 'Skills', 'Security');
	KSE::Data::SetData('Player', $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[7]{Fields}{Value}, 'Skills', 'Treat Injury');
	
	my $class_struct = $mod_playerlist->{Fields}[$mod_playerlist->fbl('ClassList')]{Value};
	
	$i = 0;
	foreach my $struct (@$class_struct)
	{
		$i++;
		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}	= $struct->{Fields}[$struct->fbl('Class')]{Value};
		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'}	= $struct->{Fields}[$struct->fbl('ClassLevel')]{Value};

		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('Class')]{Value}, 'Class' . $i, 'Class');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('ClassLevel')]{Value}, 'Class' . $i, 'Level');
		
###		KSE::Functions::Classes::SetClassInfo('Player', $i, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'});
		KSE::Functions::Classes::SetClassInfo('Player', $i, KSE::Data::GetData('Player', 'Class' . $i, 'Class'), KSE::Data::GetData('Player', 'Class' . $i, 'Level'));
		
		my $power_struct = $struct->{Fields}[$struct->fbl('KnownList0')]{Value};
		my @powers = ();
		
		if(defined($power_struct))
		{
			foreach $power (@$power_struct)
			{
				push(@powers, $power->{Fields}{Value});
			}
		}
		
###		$saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'} = \@powers;
		KSE::Data::SetData('Player', \@powers, 'Class' . $i, 'Powers')
	}
	
	my $feat_struct = $mod_playerlist->{Fields}[$mod_playerlist->fbl('FeatList')]{Value};
	my @feats = ();
	
	foreach my $struct (@$feat_struct)
	{
###		push(@{$saves{$CurrentSave}{'Player'}{'Feats'}}, $struct->{Fields}{Value});
		push(@feats, $struct->{Fields}{Value});
	}
	
	KSE::Data::SetData('Player', \@feats, 'Feats');
	my $mod_playerequiplist = $mod_playerlist->{Fields}[$mod_playerlist->fbl('Equip_ItemList')]{Value};

	foreach my $slot ('Head', 'Armor', 'Gloves', 'RWeapon', 'LWeapon', 'LArm', 'RArm', 'Implant', 'Belt', 'RWeapon2', 'LWeapon2')
	{
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = undef;
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = undef;
		
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('Player', undef, 'Equipment', $slot, 'Name_StringRef');
	}
	
	my $in = 0;
	foreach my $struct (@$mod_playerequiplist)
	{
		my $id = $struct->{ID};
		my $icon = GetIconName($id, $struct, $in);
		my $slot = KSE::Functions::Equipment::GetSlotName($id);
		
		
#		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('Tag')]{Value};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = $struct->{Fields}[$struct->fbl('Tag')]{Value};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = $icon;
#		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};
###		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};

		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('Tag')]{Value}, 'Equipment', $slot, 'Resref');
		KSE::Data::SetData('Player', $icon, 'Equipment', $slot, 'Icon');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name');
		KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'}, 'Equipment', $slot, 'Name_StringRef');
		
		if(KSE::Data::GetData('Player', 'Equipment', $slot, 'Name') == -1)
		{
#			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
###			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			KSE::Data::SetData('Player', $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'}, 'Equipment', $slot, 'Name');
		}
		else
		{
###			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'});
			KSE::Data::SetData('Player', Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'}), 'Equipment', $slot, 'Name');
		}
		
		$in++;
	}
	
	KSE::GUI::Main::GetTargetFrame()->AddTarget('Player', KSE::Functions::Portrait::GetPortraitFileByAlignment(KSE::Data::GetData('Player', 'PortraitId'), KSE::Data::GetData('Player', 'GoodEvil')), KSE::Data::GetData('Player', 'FirstName'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('Player', 'Class1', 'Class')) . ' ' . KSE::Data::GetData('Player', 'Class1', 'Level'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData('Player', 'Class2', 'Class')) . ' ' . KSE::Data::GetData('Player', 'Class2', 'Level'), KSE::Data::GetData('Player', 'HitPoints') . '/' . KSE::Data::GetData('Player', 'MaxHitPoints') . ' HP', KSE::Data::GetData('Player', 'ForcePoints') . '/' . KSE::Data::GetData('Player', 'MaxForcePoints') . ' FP');
}

# sub PopulatePlayerInfo
# {
	# my $mod_playerlist=$ModuleIFO_Obj->{Main}{Fields}[$ModuleIFO_Obj->{Main}->fbl('Mod_PlayerList')]{Value}[0];
	#
	# $saves{$CurrentSave}{'Player'}{'FirstName'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('FirstName')]{'Value'}{'Substrings'}[0]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Gender'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Gender')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'STR'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Str')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'DEX'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Dex')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'CON'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Con')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'INT'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Int')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'WIS'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Wis')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Attributes'}{'CHA'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Cha')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'HitPoints'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('HitPoints')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'MaxHitPoints'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxHitPoints')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'ForcePoints'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('ForcePoints')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'MaxForcePoints'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('MaxForcePoints')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Min1HP'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Min1HP')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Experience'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Experience')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'GoodEvil'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('GoodEvil')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Appearance_Type'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Appearance_Type')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'PortraitId'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('PortraitId')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'Race'}				= $mod_playerlist->{Fields}[$mod_playerlist->fbl('Race')]{'Value'};
	# $saves{$CurrentSave}{'Player'}{'SoundSetFile'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SoundSetFile')]{'Value'};
	#
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Computer Use'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[0]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Demolitions'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[1]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Stealth'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[2]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Awareness'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[3]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Persuade'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[4]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Repair'}			= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[5]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Security'}		= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[6]{Fields}{Value};
	# $saves{$CurrentSave}{'Player'}{'Skills'}{'Treat Injury'}	= $mod_playerlist->{Fields}[$mod_playerlist->fbl('SkillList')]{'Value'}[7]{Fields}{Value};
	#
	# my $class_struct = $mod_playerlist->{Fields}[$mod_playerlist->fbl('ClassList')]{Value};
	#
	# my $i = 0;
	# foreach my $struct (@$class_struct)
	# {
	#	 $i++;
	#	 $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}	= $struct->{Fields}[$struct->fbl('Class')]{Value};
	#	 $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'}	= $struct->{Fields}[$struct->fbl('ClassLevel')]{Value};
		#
		# KSE::Functions::Classes::SetClassInfo('Player', $i, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Class'}, $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Level'});
		#
		# my $power_struct = $struct->{Fields}[$struct->fbl('KnownList0')]{Value};
		# my @powers = ();
		#
		# if(defined($power_struct))
		# {
			# foreach my $power (@$power_struct)
			# {
# #				print "Adding " . $power->{Fields}{Value} . " to array\n";
				# push(@powers, $power->{Fields}{Value});
			# }
		# }
		#
		# $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'} = \@powers;
# #		print "i: $i CurrentSave: $CurrentSave Array: @powers\nArray2: " . $saves{$CurrentSave}{'Player'}{'Class' . $i}{'Powers'} . "\nPowers:\t" . join(", ", @powers) . "\n";
	# }
	# 
	# my $feat_struct = $mod_playerlist->{Fields}[$mod_playerlist->fbl('FeatList')]{Value};
	#
	# foreach my $struct (@$feat_struct)
	# {
		# push(@{$saves{$CurrentSave}{'Player'}{'Feats'}}, $struct->{Fields}{Value});
	# }
	#
	# my $mod_playerequiplist = $mod_playerlist->{Fields}[$mod_playerlist->fbl('Equip_ItemList')]{Value};
	#
	# foreach my $slot ('Head', 'Armor', 'Gloves', 'RWeapon', 'LWeapon', 'LArm', 'RArm', 'Implant', 'Belt', 'RWeapon2', 'LWeapon2')
	# {
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = undef;
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = undef;
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = undef;
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = undef;
	# }
	#
	# my $in = 0;
	# foreach my $struct (@$mod_playerequiplist)
	# {
		# my $id = $struct->{ID};
		# my $icon = GetIconName($id, $struct, $in);
		# my $slot = KSE::Functions::Equipment::GetSlotName($id);
		#
		#
# #		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = $struct->{Fields}[$struct->fbl('Tag')]{Value};
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Resref'} = 'saved';
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Icon'} = $icon;
# #		$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'StringRef'};
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};
		# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name_StringRef'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'StringRef'};
		#
		# if($saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} == -1)
		# {
# #			$saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $mod_playerequiplist->[$in]{Fields}[$mod_playerequiplist->[$in]->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = $struct->{Fields}[$struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
		# }
		# else
		# {
			# $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $saves{$CurrentSave}{'Player'}{'Equipment'}{$slot}{'Name'});
		# }
		#
		# $in++;
	# }
	#
	# # Now that all of the data has been loaded, we need to be ready to assign it, since the player is the default edit option.
# #	foreach('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA', 'Computer Use', 'Demolitions', 'Stealth', 'Awareness', 'Persuade', 'Repair', 'Security', 'Treat Injury')
# #	{
# #		KSE::GUI::Main::SetGUIData('Player', 'SpinButtonControls', $_, $saves{$CurrentSave}{'Player'}{$_});
# #	}
# #	
# #	KSE::GUI::Main::SetGUIData('Player', 'Appearance', 'Row', $saves{$CurrentSave}{'Player'}{'Appearance_Type'});
# #	KSE::GUI::Main::SetGUIData('Player', 'Portrait', 'Row', $saves{$CurrentSave}{'Player'}{'PortraitId'});
# #	KSE::GUI::Main::SetGUIData('Player', 'Soundset', 'Row', $saves{$CurrentSave}{'Player'}{'SoundSetFile'});
# #	
# #	KSE::GUI::Main::SetGUIData('Player', 'TextEntryControls', 'FirstName', $saves{$CurrentSave}{'Player'}{'FirstName'});
# #	
# #	KSE::GUI::Main::SetGUIData('Player', 'RadioOptionsControls', 'Gender', $saves{$CurrentSave}{'Player'}{'Gender'});
# #
# #	KSE::GUI::Main::SetGUIData('Player', 'SpinButtonControls', 'CHP', $saves{$CurrentSave}{'Player'}{'HitPoints'});
# #	KSE::GUI::Main::SetGUIData('Player', 'SpinButtonControls', 'MHP', $saves{$CurrentSave}{'Player'}{'MaxPoints'});
# #	KSE::GUI::Main::SetGUIData('Player', 'SpinButtonControls', 'CFP', $saves{$CurrentSave}{'Player'}{'ForcePoints'});
# #	KSE::GUI::Main::SetGUIData('Player', 'SpinButtonControls', 'MFP', $saves{$CurrentSave}{'Player'}{'MaxForcePoints'});
# #	
	# KSE::GUI::Main::GetTargetFrame()->AddTarget('Player', KSE::Functions::Portrait::GetPortraitFileByAlignment($saves{$CurrentSave}{'Player'}{'PortraitId'}, $saves{$CurrentSave}{'Player'}{'GoodEvil'}), $saves{$CurrentSave}{'Player'}{'FirstName'}, KSE::Functions::Classes::GetClassName($saves{$CurrentSave}{'Player'}{'Class1'}{'Class'}) . ' ' . $saves{$CurrentSave}{'Player'}{'Class1'}{'Level'}, KSE::Functions::Classes::GetClassName($saves{$CurrentSave}{'Player'}{'Class2'}{'Class'}) . ' ' . $saves{$CurrentSave}{'Player'}{'Class2'}{'Level'}, $saves{$CurrentSave}{'Player'}{'HitPoints'} . '/' . $saves{$CurrentSave}{'Player'}{'MaxHitPoints'} . ' HP', $saves{$CurrentSave}{'Player'}{'ForcePoints'} . '/' . $saves{$CurrentSave}{'Player'}{'MaxForcePoints'} . ' FP');
# }

return 1;