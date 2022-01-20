#line 1 "KSE/GUI/SpinboxControls.pm"
package KSE::GUI::SpinboxControls; #TimePlayed, Attributes, HitPoints, ForcePoints, Skills

use KSE::Data;

use Tk;
use Tk::LabFrame;
use Tk::Label;
use Tk::Spinbox;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'} = $type;
	$self->{'Data'} = {};
	$self->{'GUI'} = {};
    bless $self,$class;
    return $self;
}

sub GetDataPiece
{
	my ($self, $piece) = @_;

	return $self->{'Data'}{$piece};
}

sub SetDataPiece
{
	my ($self, $piece, $data) = @_;
	
	$self->{'Data'}{$piece} = $data;
}

sub ChangeTarget
{
	my ($self, $target, @pieces) = @_;
	$self->{'Type'} = $target;
	
	foreach my $piece (@pieces)
	{
		if($piece eq 'Influence')
		{
			if(KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave()) == 2)
			{
				if($target ne 'Player')
				{
					if($self->{'GUI'}{'Influence_packed'} == 0)
					{
						$self->{'GUI'}{'Influence'}->pack(-side=>'top', -pady=>35, -anchor=>'s', -padx=>5);
						$self->{'GUI'}{'Influence_packed'} = 1;
					}
					
#					$self->{'Data'}{$piece} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), $piece);
					KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), $piece), 'Influence');
				}
				else
				{
					$self->{'GUI'}{'Influence'}->packForget;
					$self->{'GUI'}{'Influence_packed'} = 0;
				}
			}
		}
		elsif($piece eq 'Attributes')
		{
			foreach('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')
			{
#				$self->{'Data'}{$_} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', $_);
				KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'Attributes', $_), $_);
			}
		}
		elsif($piece eq 'Skills')
		{
			foreach('Computer Use', 'Demolitions', 'Stealth', 'Awareness', 'Persuade', 'Repair', 'Security', 'Treat Injury')
			{
#				$self->{'Data'}{$_} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', $_);
				KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'Skills', $_), $_);
			}
		}
		elsif($piece eq 'HitPoints')
		{
#			$self->{'Data'}{'CHP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'HitPoints');
#			$self->{'Data'}{'MHP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'MaxHitPoints');
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'HitPoints'), 'CHP');
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'MaxHitPoints'), 'MHP');
		}
		elsif($piece eq 'ForcePoints')
		{
#			$self->{'Data'}{'CFP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'ForcePoints');
#			$self->{'Data'}{'MFP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'MaxForcePoints');
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'ForcePoints'), 'CFP');
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'MaxForcePoints'), 'MFP');
		}
		elsif($piece eq 'TimePlayed')
		{
			my $time = KSE::Data::GetData('None', 'TIMEPLAYED');
			KSE::Data::SetGUIData(($time / 3600), 'Hours');
			KSE::Data::SetGUIData((($time % 3600) / 60), 'Minutes');
			KSE::Data::SetGUIData(($time % 60), 'Seconds');
		}
		else
		{
#			print "Getting " . uc($piece) . "\n";
			KSE::Data::SetGUIData(KSE::Data::GetData('None', uc $piece), $piece);
		}
	}
}

sub AdjustTime
{
#	print "Arguments: \n\t";
#	print join "\n\t", @_;
#	print "\n";
	
	my ($self, $period, $value, $incdec) = @_;
	
	if($value == 60)
	{
		if($period eq 'Minutes')
		{
			$self->{'Data'}{'Hours'} += 1;
		}
		else
		{
			$self->{'Data'}{'Minutes'} += 1;
			
			$self->AdjustTime('Minutes', $self->{'Data'}{'Minutes'}, $incdec);
		}
		
		$self->{'Data'}{$period} = 0;
	}
	
	KSE::Data::SetData(('None', ($self->{'Data'}{'Hours'}*3600) + ($self->{'Data'}{'Minutes'}*60)+($self->{'Data'}{'Seconds'})), 'TIMEPLAYED');
}

sub Create
{
	my ($self, $parent, @controls) = @_;
	
	$self->{'GUI'}{'Parent'}	= $parent;
	
	foreach my $control (@controls)
	{
#		print "Control: $control\n";
		$self->{'Data'}{$control} = '';
		
		if($control eq 'TimePlayed')
		{
#			$self->{'Data'}{'Hours'}	= KSE::Functions::Saves::GetSaveData('TIMEPLAYED') / 3600;
#			$self->{'Data'}{'Minutes'}	= (KSE::Functions::Saves::GetSaveData('TIMEPLAYED') % 3600) / 60;
#			$self->{'Data'}{'Seconds'}	= KSE::Functions::Saves::GetSaveData('TIMEPLAYED') % 60;
			
			KSE::Data::SetGUIData(0, 'Hours');
			KSE::Data::SetGUIData(0, 'Minutes');
			KSE::Data::SetGUIData(0, 'Seconds');
			
			$self->{'GUI'}{'Frame_TimePlayed'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			
			$self->{'GUI'}{'Frame_TimePlayed'}->Label(-text=>'Time Played: ', -width=>25, -anchor=>'w', -justify=>'left')->pack(-fill=>'x', -padx=>5);
			
			$self->{'GUI'}{'Timers'} = $self->{'GUI'}{'Frame_TimePlayed'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5, -padx=>5);
			
			$self->{'GUI'}{'Timers'}->Label(-text=>'H  ')->pack(-side=>'left');
			$self->{'GUI'}{'Timers'}{'H'} = $self->{'GUI'}{'Timers'}->Spinbox(-from=>0, -to=>59, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Hours'), -width=>4, -state=>'readonly', -readonlybackground=>'white')->pack(-side=>'left');
			
			$self->{'GUI'}{'Timers'}->Label(-text=>'M  ')->pack(-side=>'left');
			$self->{'GUI'}{'Timers'}{'M'} = $self->{'GUI'}{'Timers'}->Spinbox(-from=>0, -to=>60, -increment=>1, -command=>sub { $self->AdjustTime('Minutes', @_); }, -textvariable=>KSE::Data::GetGUIDataRef('Minutes'), -width=>4, -state=>'readonly', -readonlybackground=>'white')->pack(-side=>'left');
			
			$self->{'GUI'}{'Timers'}->Label(-text=>'S  ')->pack(-side=>'left');
			$self->{'GUI'}{'Timers'}{'S'} = $self->{'GUI'}{'Timers'}->Spinbox(-from=>0, -to=>60, -increment=>1, -command=>sub { $self->AdjustTime('Seconds', @_); }, -textvariable=>KSE::Data::GetGUIData('Seconds'), -width=>4, -state=>'readonly', -readonlybackground=>'white')->pack(-side=>'left');
		}
		elsif($control eq 'Attributes')
		{
#			$self->{'Data'}{'STR'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'STR');
#			$self->{'Data'}{'DEX'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'DEX');
#			$self->{'Data'}{'CON'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'CON');
#			$self->{'Data'}{'INT'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'INT');
#			$self->{'Data'}{'WIS'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'WIS');
#			$self->{'Data'}{'CHA'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Attributes', 'CHA');
			
			KSE::Data::SetGUIData(0, 'STR');
			KSE::Data::SetGUIData(0, 'DEX');
			KSE::Data::SetGUIData(0, 'CON');
			KSE::Data::SetGUIData(0, 'INT');
			KSE::Data::SetGUIData(0, 'WIS');
			KSE::Data::SetGUIData(0, 'CHA');

			$self->{'GUI'}{'Frame_Attributes'} = $self->{'GUI'}{'Parent'}->LabFrame(-label=>'Attributes', -labelside=>'acrosstop', -height=>30, -width=>150)->pack(-side=>'left', -ipady=>5, -padx=>5);
			
			$self->{'GUI'}{'Frame_Attributes_Base1'} = $self->{'GUI'}{'Frame_Attributes'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_Attributes_Base2'} = $self->{'GUI'}{'Frame_Attributes'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_Attributes_Base3'} = $self->{'GUI'}{'Frame_Attributes'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			
			$self->{'GUI'}{'Frame_Attributes1'} = $self->{'GUI'}{'Frame_Attributes_Base1'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes1'}->Label(-text=>'Strength: ',		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Attributes1'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('STR'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('STR') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'STR'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('STR'), KSE::GUI::Target::GetTarget(), 'Attributes', 'STR'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Attributes2'} = $self->{'GUI'}{'Frame_Attributes_Base1'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes2'}->Label(-text=>'Dexterity: ',	-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Attributes2'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('DEX'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('DEX') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'DEX'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('DEX'), KSE::GUI::Target::GetTarget(), 'Attributes', 'DEX'); } })->pack(-side=>'left');

			$self->{'GUI'}{'Frame_Attributes3'} = $self->{'GUI'}{'Frame_Attributes_Base2'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes3'}->Label(-text=>'Constitution: ',	-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Attributes3'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('CON'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('CON') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'CON'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('CON'), KSE::GUI::Target::GetTarget(), 'Attributes', 'CON'); } })->pack(-side=>'left');

			$self->{'GUI'}{'Frame_Attributes4'} = $self->{'GUI'}{'Frame_Attributes_Base2'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes4'}->Label(-text=>'Intelligence: ',	-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Attributes4'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('INT'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('INT') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'INT'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('INT'), KSE::GUI::Target::GetTarget(), 'Attributes', 'INT'); } })->pack(-side=>'left');

			$self->{'GUI'}{'Frame_Attributes5'} = $self->{'GUI'}{'Frame_Attributes_Base3'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes5'}->Label(-text=>'Wisdom: ', 		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Attributes5'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('WIS'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('WIS') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'WIS'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('WIS'), KSE::GUI::Target::GetTarget(), 'Attributes', 'WIS'); } })->pack(-side=>'left');

			$self->{'GUI'}{'Frame_Attributes6'} = $self->{'GUI'}{'Frame_Attributes_Base3'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Attributes6'}->Label(-text=>'Charisma: ',		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);			
			$self->{'GUI'}{'Frame_Attributes6'}->Spinbox(-from=>1, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('CHA'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('CHA') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Attributes', 'CHA'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('CHA'), KSE::GUI::Target::GetTarget(), 'Attributes', 'CHA'); } })->pack(-side=>'left');
		}
		elsif($control eq 'Skills')
		{
			
#			$self->{'Data'}{'Computer Use'}	= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Computer Use');
#			$self->{'Data'}{'Demolitions'}	= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Demolitions');
#			$self->{'Data'}{'Stealth'}		= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Stealth');
#			$self->{'Data'}{'Awareness'}	= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Awareness');
#			$self->{'Data'}{'Persuade'}		= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Persuade');
#			$self->{'Data'}{'Repair'}		= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Repair');
#			$self->{'Data'}{'Security'}		= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Security');
#			$self->{'Data'}{'Treat Injury'}	= KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Skills', 'Treat Injury');

			KSE::Data::SetGUIData(0, 'Computer Use');
			KSE::Data::SetGUIData(0, 'Demolitions');
			KSE::Data::SetGUIData(0, 'Stealth');
			KSE::Data::SetGUIData(0, 'Awareness');
			KSE::Data::SetGUIData(0, 'Persuade');
			KSE::Data::SetGUIData(0, 'Repair');
			KSE::Data::SetGUIData(0, 'Security');
			KSE::Data::SetGUIData(0, 'Treat Injury');
			
			$self->{'GUI'}{'Frame_Skills'} = $self->{'GUI'}{'Parent'}->LabFrame(-label=>'Skills', -labelside=>'acrosstop', -height=>30, -width=>150)->pack(-side=>'left', -padx=>5);
			
			$self->{'GUI'}{'Frame_Skills_Base1'} = $self->{'GUI'}{'Frame_Skills'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5, -padx=>5);
			$self->{'GUI'}{'Frame_Skills_Base2'} = $self->{'GUI'}{'Frame_Skills'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5, -padx=>5);
			$self->{'GUI'}{'Frame_Skills_Base3'} = $self->{'GUI'}{'Frame_Skills'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5, -padx=>5);
			$self->{'GUI'}{'Frame_Skills_Base4'} = $self->{'GUI'}{'Frame_Skills'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5, -padx=>5);
			
			$self->{'GUI'}{'Frame_Skills1'} = $self->{'GUI'}{'Frame_Skills_Base1'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills1'}->Label(-text=>'Computer Use: ',		-width=>12, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills1'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Computer Use'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Computer Use') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Computer Use'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Computer Use'), KSE::GUI::Target::GetTarget(), 'Skills', 'Computer Use'); } })->pack(-side=>'left');

			$self->{'GUI'}{'Frame_Skills2'} = $self->{'GUI'}{'Frame_Skills_Base1'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills2'}->Label(-text=>'Demolitions: ',		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills2'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Demolitions'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Demolitions') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Demolitions'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Demolitions'), KSE::GUI::Target::GetTarget(), 'Skills', 'Demolitions'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills3'} = $self->{'GUI'}{'Frame_Skills_Base2'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills3'}->Label(-text=>'Stealth: ',			-width=>12, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills3'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Stealth'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Stealth') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Stealth'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Stealth'), KSE::GUI::Target::GetTarget(), 'Skills', 'Stealth'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills4'} = $self->{'GUI'}{'Frame_Skills_Base2'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills4'}->Label(-text=>'Awareness: ',		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills4'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Awareness'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Awareness') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Awareness'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Awareness'), KSE::GUI::Target::GetTarget(), 'Skills', 'Awareness'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills5'} = $self->{'GUI'}{'Frame_Skills_Base3'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills5'}->Label(-text=>'Persuade: ',			-width=>12, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills5'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Persuade'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Persuade') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Persuade'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Persuade'), KSE::GUI::Target::GetTarget(), 'Skills', 'Persuade'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills6'} = $self->{'GUI'}{'Frame_Skills_Base3'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills6'}->Label(-text=>'Repair: ',			-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills6'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Repair'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Repair') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Repair'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Repair'), KSE::GUI::Target::GetTarget(), 'Skills', 'Repair'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills7'} = $self->{'GUI'}{'Frame_Skills_Base4'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills7'}->Label(-text=>'Security: ',			-width=>12, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills7'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Security'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Security') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Security'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Security'), KSE::GUI::Target::GetTarget(), 'Skills', 'Security'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_Skills8'} = $self->{'GUI'}{'Frame_Skills_Base4'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -pady=>5);
			$self->{'GUI'}{'Frame_Skills8'}->Label(-text=>'Treat Injury: ',		-width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Skills8'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Treat Injury'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Treat Injury') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Skills', 'Treat Injury'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Treat Injury'), KSE::GUI::Target::GetTarget(), 'Skills', 'Treat Injury'); } })->pack(-side=>'left');
		}
		elsif($control eq 'HitPoints')
		{
#			$self->{'Data'}{'CHP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'HitPoints');
#			$self->{'Data'}{'MHP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'MaxHitPoints');

			KSE::Data::SetGUIData(0, 'CHP');
			KSE::Data::SetGUIData(0, 'MHP');
			
			$self->{'GUI'}{'Frame_Points'} = $self->{'GUI'}{'Parent'}->LabFrame(-label=>'HP and FP', -labelside=>'acrosstop', -height=>30, -width=>150)->pack(-side=>'left', -padx=>5);
			
			$self->{'GUI'}{'Frame_HitPoints'} = $self->{'GUI'}{'Frame_Points'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -padx=>5, -pady=>5);
			
			$self->{'GUI'}{'Frame_HitPoints1'} = $self->{'GUI'}{'Frame_HitPoints'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Frame_HitPoints1'}->Label(-text=>'Current Hit Points: ', -width=>17, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_HitPoints1'}->Spinbox(-from=>0, -to=>2500, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('CHP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('CHP') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'HitPoints'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('CHP'), KSE::GUI::Target::GetTarget(), 'HitPoints'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_HitPoints2'} = $self->{'GUI'}{'Frame_HitPoints'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Frame_HitPoints2'}->Label(-text=>'Max Hit Points: ', -width=>17, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_HitPoints2'}->Spinbox(-from=>0, -to=>2500, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('MHP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('MHP') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'MaxHitPoints'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('MHP'), KSE::GUI::Target::GetTarget(), 'MaxHitPoints'); } })->pack(-side=>'left');
		}
		elsif($control eq 'ForcePoints')
		{
#			$self->{'Data'}{'CFP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'ForcePoints');
#			$self->{'Data'}{'MFP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'MaxForcePoints');

			KSE::Data::SetGUIData(0, 'CFP');
			KSE::Data::SetGUIData(0, 'MFP');
			
			$self->{'GUI'}{'Frame_ForcePoints'} = $self->{'GUI'}{'Frame_Points'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -padx=>5, -pady=>5);
			
			$self->{'GUI'}{'Frame_ForcePoints1'} = $self->{'GUI'}{'Frame_ForcePoints'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Frame_ForcePoints1'}->Label(-text=>'Current Force Points: ', -width=>17, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_ForcePoints1'}->Spinbox(-from=>0, -to=>2500, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('CFP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('CFP') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'ForcePoints'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('CFP'), KSE::GUI::Target::GetTarget(), 'ForcePoints'); } })->pack(-side=>'left');
			
			$self->{'GUI'}{'Frame_ForcePoints2'} = $self->{'GUI'}{'Frame_ForcePoints'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Frame_ForcePoints2'}->Label(-text=>'Max Force Points: ', -width=>17, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_ForcePoints2'}->Spinbox(-from=>0, -to=>2500, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('MFP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('MFP') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'MaxForcePoints'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('MFP'), KSE::GUI::Target::GetTarget(), 'MaxForcePoints'); } })->pack(-side=>'left');

		}
		elsif($control eq 'Components')
		{
#			$self->{'Data'}{'Components'} = KSE::Functions::Saves::GetSaveData('Components');
			KSE::Data::SetGUIData(0, 'Components');
			
			$self->{'GUI'}{'Frame_Materials'} = $self->{'GUI'}{'Frame_CR_XP_CMP'}->LabFrame(-label=>'Crafting Materials', -labelside=>'acrosstop', -height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_Materials1'} = $self->{'GUI'}{'Frame_Materials'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x');
			
			$self->{'GUI'}{'Frame_Materials1'}->Label(-text=>'Components: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Materials1'}->Spinbox(-from=>0, -to=>2500000, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Components'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
#				print "0 is $_[0].\n1 is $_[1].\n2 is $_[2].\n3 is $_[3].\n4 is $_[4].\n5 is $_[5].\n6 is $_[6].\n";
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				if($_[0] eq '')
				{
#					$self->{'Data'}{'Components'} = 0;
				}
#				print "You passed!\n";
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Components') eq '') { KSE::Functions::Saves::SetSaveData(0, 'Components'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Components'), 'Components'); } })->pack(-side=>'left');
		}
		elsif($control eq 'Chemicals')
		{
#			$self->{'Data'}{'Chemicals'} = KSE::Functions::Saves::GetSaveData('Chemicals');
			KSE::Data::SetGUIData(0, 'Chemicals');

			$self->{'GUI'}{'Frame_Materials2'} = $self->{'GUI'}{'Frame_Materials'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x');
			
			$self->{'GUI'}{'Frame_Materials2'}->Label(-text=>'Chemicals: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Materials2'}->Spinbox(-from=>0, -to=>2500000, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Chemicals'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Chemicals') eq '') { KSE::Functions::Saves::SetSaveData(0, 'Chemicals'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Chemicals'), 'Chemicals'); } })->pack(-side=>'left');
		}
		elsif($control eq 'Credits')
		{
#			$self->{'Data'}{'Credits'} = KSE::Functions::Saves::GetSaveData('CREDITS');
			KSE::Data::SetGUIData(0, 'Credits');
			
			$self->{'GUI'}{'Frame_CR_XP_CMP'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>30)->pack(-fill=>'y', -padx=>5);
			
			$self->{'GUI'}{'CR_XP'} = $self->{'GUI'}{'Frame_CR_XP_CMP'}->LabFrame(-label=>'Currency and XP', -labelside=>'acrosstop', -height=>30, -width=>150)->pack(-fill=>'x');
			
			$self->{'GUI'}{'Frame_Credits'} = $self->{'GUI'}{'CR_XP'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			
			$self->{'GUI'}{'Frame_Credits'}->Label(-text=>'Current Credits: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Credits'}->Spinbox(-from=>0, -to=>2500000, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Credits'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Credits') eq '') { KSE::Functions::Saves::SetSaveData(0, 'Credits'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Credits'), 'CREDITS'); } })->pack(-side=>'left');
		}
		elsif($control eq 'XP')
		{
#			$self->{'Data'}{'PlayerXP'} = KSE::Functions::Saves::GetSaveData('Player', 'Experience');
			KSE::Data::SetGUIData(0, 'PlayerXP');
			
			$self->{'GUI'}{'Frame_Experience'} = $self->{'GUI'}{'CR_XP'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x');
			
			$self->{'GUI'}{'Frame_XP'} = $self->{'GUI'}{'Frame_Experience'}->Frame(-height=>30, -width=>150)->pack();
			$self->{'GUI'}{'Frame_XP'}->Label(-text=>'Player Experience: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_XP'}->Spinbox(-from=>0, -to=>250000000, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('PlayerXP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('PlayerXP') eq '') { KSE::Functions::Saves::SetSaveData(0, 'Player', 'Experience'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('PlayerXP'), 'Player', 'Experience'); } })->pack(-side=>'left');
		}
		elsif($control eq 'Party XP')
		{
#			$self->{'Data'}{'PartyXP'} = KSE::Functions::Saves::GetSaveData('PARTYXP');
			KSE::Data::SetGUIData(0, 'PartyXP');
			
			$self->{'GUI'}{'Frame_PXP'} = $self->{'GUI'}{'Frame_Experience'}->Frame(-height=>30, -width=>150)->pack();
			$self->{'GUI'}{'Frame_PXP'}->Label(-text=>'Party Experience: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_PXP'}->Spinbox(-from=>0, -to=>250000000, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('PartyXP'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('PartyXP') eq '') { KSE::Functions::Saves::SetSaveData(0, 'PARTYXP'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('PartyXP'), 'PARTYXP'); } })->pack(-side=>'left');
		}
		elsif($control eq 'Influence')
		{
#			$self->{'Data'}{'Influence'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Influence');
			KSE::Data::SetGUIData(0, 'Influence');

			$self->{'GUI'}{'Influence'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-side=>'top', -pady=>5, -anchor=>'center', -padx=>5);

			$self->{'GUI'}{'Influence'}->Label(-text=>'Influence: ', -width=>10)->pack(-side=>'left');
			$self->{'GUI'}{'Influence'}->Spinbox(-from=>0, -to=>100, -increment=>1, -textvariable=>KSE::Data::GetGUIDataRef('Influence'), -width=>5, -state=>'normal', -validate=>'key', -validatecommand=>sub {
				if($_[1] eq '') 		{ return 1; }#print "error 1\n"; return 1; }
				if(defined($_[1]) == 0) { return 1; }#print "error 2\n"; return 1; }
				if($_[1] =~ /\D/)		{ return 0; }#print "error 3\n"; return 0; }
				
				return 1;
			}, -readonlybackground=>'white', -command=>sub { if(KSE::Data::GetGUIData('Influence') eq '') { KSE::Functions::Saves::SetSaveData(0, KSE::GUI::Target::GetTarget(), 'Influence'); } else { KSE::Functions::Saves::SetSaveData(KSE::Data::GetGUIData('Influence'), KSE::GUI::Target::GetTarget(), 'Influence'); } })->pack(-side=>'left');
		}
	}
}

sub ValidateNumber
{
	return 1;
	my $value = $_[1];
	
#	print "Arguments:\n\t";
#	print join "\n\t", @_;
#	print "\n";
	

	if(defined($value) == 0) { return 0; }
	
	if($value =~ /\w/)
	{
		print "cancel\n";
		return 0;
	}
	
	return 1;
}

sub destroy
{
	my $self = shift;

#	foreach ($self->{'GUI'}{'Frame'}->children)
#	{
#		$_->destroy;
#	}
	foreach (keys %{$self->{'GUI'}})
	{
		delete $self->{'GUI'}{$_};
	}
	foreach (keys %{$self->{'Data'}})
	{
		delete $self->{'Data'}{$_};
	}
	
	delete $self->{'GUI'};
	delete $self->{'Data'};
	delete $self->{'Type'};
	
	$self = undef;
}

return 1;