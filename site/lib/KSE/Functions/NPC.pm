#line 1 "KSE/Functions/NPC.pm"
package KSE::Functions::NPC;

use KSE::Functions::Saves;
use KSE::Functions::Classes;
use KSE::Functions::Portrait;

my %NPC_Data;
my %NPC_Index;

sub ClearNPCHashes
{
	%NPC_Data = ();
	%NPC_Index = ();
}

sub SetData
{
	my ($npc, $data, @paths) = @_;

	unshift(@paths, 'NPC' . $npc);
	KSE::Functions::Saves::SetSaveData($data, @paths);
}

sub GetData
{
	my ($npc, @paths) = @_;
	unshift(@paths, 'NPC' . $npc);
	return KSE::Functions::Saves::GetSaveData(@paths);
}

#sub SaveAllNPCs
#{
#	foreach (keys %NPC_Data)
#	{
#		SetData($npc, $NPC_Data{$npc}{'Name'}, 'FirstName');
#		SetData($npc, $NPC_Data{$npc}{'Class1'}, 'Class1', 'Class');
#		SetData($npc, $NPC_Data{$npc}{'Class1Level'}, 'Class1', 'Level');
#		SetData($npc, $NPC_Data{$npc}{'Class2'}, 'Class2', 'Class');
#		SetData($npc, $NPC_Data{$npc}{'Class2Level'}, 'Class2', 'Level');
#		SetData($npc, $NPC_Data{$npc}{''}, 'FirstName');
#	}
#}

sub UpdateNPC
{
	my $npc = shift;
	
	$NPC_Data{$npc}{'Name'}			= KSE::Data::GetData('NPC' . $npc, 'FirstName');
	$NPC_Data{$npc}{'HP'}			= KSE::Data::GetData('NPC' . $npc, 'HitPoints') . '/' . KSE::Data::GetData('NPC' . $npc, 'MaxHitPoints');
	$NPC_Data{$npc}{'FP'}			= KSE::Data::GetData('NPC' . $npc, 'ForcePoints') . '/' . KSE::Data::GetData('NPC' . $npc, 'MaxForcePoints');
	$NPC_Data{$npc}{'Class1'}		= KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $npc, 'Class1', 'Class'));
	$NPC_Data{$npc}{'Class1Level'}	= KSE::Data::GetData('NPC' . $npc, 'Class1', 'Level');
	$NPC_Data{$npc}{'Class2'}		= KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $npc, 'Class2', 'Class'));
	$NPC_Data{$npc}{'Class2Level'}	= KSE::Data::GetData('NPC' . $npc, 'Class2', 'Level');
	$NPC_Data{$npc}{'Portrait'}		= KSE::Functions::Portrait::GetPortraitFile(KSE::Data::GetData('NPC' . $npc, 'PortraitId'), 'baseresref');
	
	$NPC_Index{$npc} = $NPC_Data{$npc}{'Name'};
}

sub AddNPC
{
	my $npc = shift;
#	print "Adding NPC $npc\n";
#	print "PortraitId: " . GetData($npc, 'PortraitId') . "\n";
#	print "Portrait File: " . KSE::Functions::Portrait::GetPortraitFile(KSE::Data::GetData($npc, 'PortraitId'), 'baseresref') . "\n";
	$NPC_Data{'Exists'}{$npc} = 1;
	
	$NPC_Data{$npc}{'Name'}			= KSE::Data::GetData('NPC' . $npc, 'FirstName');
	$NPC_Data{$npc}{'HP'}			= KSE::Data::GetData('NPC' . $npc, 'HitPoints') . '/' . KSE::Data::GetData('NPC' . $npc, 'MaxHitPoints');
	$NPC_Data{$npc}{'FP'}			= KSE::Data::GetData('NPC' . $npc, 'ForcePoints') . '/' . KSE::Data::GetData('NPC' . $npc, 'MaxForcePoints');
	$NPC_Data{$npc}{'Class1'}		= KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $npc, 'Class1', 'Class'));
	$NPC_Data{$npc}{'Class1Level'}	= KSE::Data::GetData('NPC' . $npc, 'Class1', 'Level');
	$NPC_Data{$npc}{'Class2'}		= KSE::Functions::Classes::GetClassName(KSE::Data::GetData('NPC' . $npc, 'Class2', 'Class'));
	$NPC_Data{$npc}{'Class2Level'}	= KSE::Data::GetData('NPC' . $npc, 'Class2', 'Level');
	$NPC_Data{$npc}{'Portrait'}		= KSE::Functions::Portrait::GetPortraitFile(KSE::Data::GetData('NPC' . $npc, 'PortraitId'), 'baseresref');
	
	$NPC_Index{$npc} = $NPC_Data{$npc}{'Name'};
}

sub GetNPCExists
{
#	print "Arguments:\n\t";
#	print join ("\n\t", @_);
	
	my $npc = shift;
	if(defined($NPC_Data{'Exists'}{$npc}) == 0)
	{
		$NPC_Data{'Exists'}{$npc} = 0;
	}
		
	return $NPC_Data{'Exists'}{$npc};
}

sub GetName
{
#	print "Arguments:\n\t";
#	print join ("\n\t", @_);
#	print "\n";

	my $npc = shift;
	
	return $NPC_Data{$npc}{'Name'};
}

sub GetClass
{
	my ($npc, $class_index) = @_;
	
	return $NPC_Data{$npc}{'Class' . $class_index};
}

sub GetHP
{
	my $npc = shift;
	
	return $NPC_Data{$npc}{'HP'};
}

sub GetFP
{
	my $npc = shift;
	
	return $NPC_Data{$npc}{'FP'};
}

sub GetPortrait
{
#	print "Arguments:\n\t";
#	print join ("\n\t", @_);
#	print "\n";
	my $npc = shift;

	return $NPC_Data{$npc}{'Portrait'};
}

sub GetNPCNames
{
	my @names = ();
	
	foreach (sort {$a <=> $b} keys %NPC_Index)
	{
		push(@names, $NPC_Index{$_});
	}
	
	return @names;
}

sub GetNPCIndex
{
	my $name = shift;
	
	my %n = reverse %NPC_Index;
	
	return $n{$name};
}

return 1;