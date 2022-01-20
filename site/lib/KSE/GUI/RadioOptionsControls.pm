#line 1 "KSE/GUI/RadioOptionsControls.pm"
package KSE::GUI::RadioOptionsControls; #Gender, CheatUsed, Min1HP, CurrentParty

use KSE::Data;

use Tk;
use Tk::LabFrame;
use Tk::Label;
use Tk::Radiobutton;

my $npc1_count = 0;
my $npc1_frame = 1;
my $npc2_count = 0;
my $npc2_frame = 1;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'} = $type;
	$self->{'Data'} = {};
	$self->{'GUI'} = {};
	$self->{'gflag'} = -1;
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
#		$self->{'Data'}{$piece} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), $piece);
#		KSE::Data::SetGUIData(KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), $piece), $piece);
		if($piece eq 'CurrentParty')
		{
			KSE::Data::SetGUIData(KSE::Data::GetData('None', 'PT_MEMBER1'), 'PT_MEMBER1');
			KSE::Data::SetGUIData(KSE::Data::GetData('None', 'PT_MEMBER2'), 'PT_MEMBER2');
			
			if(defined(KSE::Data::GetGUIData('PT_MEMBER1')) == 0)
			{
				KSE::Data::SetGUIData(-1, 'PT_MEMBER1');
			}
			if(defined(KSE::Data::GetGUIData('PT_MEMBER2')) == 0)
			{
				KSE::Data::SetGUIData(-1, 'PT_MEMBER2');
			}
			
			foreach($self->{'GUI'}{'Frame_Current1_1'}->children)
			{
				$_->destroy;
			}
			foreach($self->{'GUI'}{'Frame_Current2_1'}->children)
			{
				$_->destroy;
			}
			
			my $npc1_count = 0;
			my $npc2_count = 0;
			foreach my $name (KSE::Functions::NPC::GetNPCNames())
			{
#				if($npc1_count > 4) { $npc1_frame = 2; }
				if($npc1_count > 4) { $npc1_frame = 1; }
				else                { $npc1_frame = 1; }
				$self->{'gflag'} = KSE::Functions::NPC::GetNPCIndex($name);
				$self->{'GUI'}{'Frame_Current1_' . $npc1_frame}->Radiobutton(-text=>$name, -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER1'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('PT_MEMBER1'), 'PT_MEMBER1'); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
				$npc1_count++;
				
#				if($npc2_count > 4) { $npc2_frame = 2; }
				if($npc2_count > 4) { $npc2_frame = 1; }
				else                { $npc2_frame = 1; }
#				$self->{'gflag'} = KSE::Functions::NPC::GetNPCIndex($name);
				$self->{'GUI'}{'Frame_Current2_' . $npc2_frame}->Radiobutton(-text=>$name, -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER2'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('PT_MEMBER2'), 'PT_MEMBER2'); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
				$npc2_count++;
			}
		}
		elsif($piece eq 'CheatUsed')
		{
			KSE::Data::SetGUIData(KSE::Data::GetData('None', uc $piece), $piece);
			if(defined(KSE::Data::GetGUIData('CheatUsed')) == 0)
			{
				KSE::Data::SetGUIData(0, 'CheatUsed');
			}
		}
		elsif($piece eq 'SoloMode')
		{
			KSE::Data::SetGUIData(KSE::Data::GetData('None', uc $piece), $piece);
			if(defined(KSE::Data::GetGUIData('SoloMode')) == 0)
			{
				KSE::Data::SetGUIData(0, 'SoloMode');
			}
		}
		else
		{
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), $piece), $piece);
		}
	}
}

sub Create
{
	my ($self, $parent, @controls) = @_;
	
	$self->{'GUI'}{'Parent'}	= $parent;
		
	foreach my $control (@controls)
	{
		$self->{'Data'}{$control} = '';
		
		if($control eq 'Gender')
		{
#			$self->{'Data'}{'Gender'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Gender');
			KSE::Data::SetGUIData(KSE::GUI::Target::GetTarget(), 0, 'Gender');
			
			$self->{'GUI'}{'Frame_Gender'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Gender'}->Label(-text=>'Gender: ', -width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			
			foreach('Male', 'Female', 'Both', 'Other', 'None')
			{
				$self->{'gflag'}++;
#				$self->{'GUI'}{'Frame_Gender'}->Radiobutton(-text=>$_, -value=>$self->{'gflag'}, -variable=>\$self->{'Data'}{$control})->pack(-side=>'left', -anchor=>'w');
				$self->{'GUI'}{'Frame_Gender'}->Radiobutton(-text=>$_, -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('Gender'), -command=>sub { KSE::Data::SetData(KSE::GUI::Target::GetTarget(), KSE::Data::GetGUIData('Gender'), 'Gender'); })->pack(-side=>'left', -anchor=>'w');
			}
			
			$gflag = -1;
		}
		elsif($control eq 'CheatUsed')
		{
#			$self->{'Data'}{'CheatUsed'} = KSE::Functions::Saves::GetSaveData('CHEATUSED') | KSE::Functions::Saves::GetSaveData('PT_CHEAT');
			KSE::Data::SetGUIData(0, 'CheatUsed');
			
			$self->{'GUI'}{'Frame_CheatUsed'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_CheatUsed'}->Label(-text=>'Cheats used: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_CheatUsed'}->Radiobutton(-text=>'No', -value=>0, -variable=>KSE::Data::GetGUIDataRef('CheatUsed'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('CheatUsed'), 'CHEATUSED'); })->pack(-side=>'left', -anchor=>'w');
			$self->{'GUI'}{'Frame_CheatUsed'}->Radiobutton(-text=>'Yes', -value=>1, -variable=>KSE::Data::GetGUIDataRef('CheatUsed'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('CheatUsed'), 'CHEATUSED'); })->pack(-side=>'left', -anchor=>'w');
		}
		elsif($control eq 'SoloMode')
		{
#			$self->{'Data'}{'SoloMode'} = KSE::Functions::Saves::GetSaveData('SOLOMODE');
			KSE::Data::SetGUIData(0, 'SoloMode');
			
			$self->{'GUI'}{'Frame_SoloMode'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_SoloMode'}->Label(-text=>'Solo Mode: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_SoloMode'}->Radiobutton(-text=>'No', -value=>0, -variable=>KSE::Data::GetGUIDataRef('SoloMode'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('SoloMode'), 'SOLOMODE'); })->pack(-side=>'left', -anchor=>'w');
			$self->{'GUI'}{'Frame_SoloMode'}->Radiobutton(-text=>'Yes', -value=>1, -variable=>KSE::Data::GetGUIDataRef('SoloMode'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('SoloMode'), 'SOLOMODE'); })->pack(-side=>'left', -anchor=>'w');
		}
		elsif($control eq 'Min1HP')
		{
#			$self->{'Data'}{'Min1HP'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Min1HP');
			KSE::Data::SetGUIData(0, 'Min1HP');
			
			$self->{'GUI'}{'Frame_Min1HP'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -padx=>15);
			$self->{'GUI'}{'Frame_Min1HP'}->Label(-text=>'Invincible: ', -width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Min1HP'}->Radiobutton(-text=>'No', -value=>0, -variable=>KSE::Data::GetGUIDataRef('Min1HP'), -command=>sub { KSE::Data::SetData(KSE::GUI::Target::GetTarget(), KSE::Data::GetGUIData('Min1HP'), 'Min1HP'); })->pack(-side=>'left', -anchor=>'w');
			$self->{'GUI'}{'Frame_Min1HP'}->Radiobutton(-text=>'Yes', -value=>1, -variable=>KSE::Data::GetGUIDataRef('Min1HP'), -command=>sub { KSE::Data::SetData(KSE::GUI::Target::GetTarget(), KSE::Data::GetGUIData('Min1HP'), 'Min1HP'); })->pack(-side=>'left', -anchor=>'w');
		}
		else # It's the CurrentParty
		{
#			$self->{'Data'}{'PT_MEMBER1'} = KSE::Functions::Saves::GetSaveData('PT_MEMBER1');
#			$self->{'Data'}{'PT_MEMBER2'} = KSE::Functions::Saves::GetSaveData('PT_MEMBER2');
			KSE::Data::SetGUIData(-1, 'PT_MEMBER1');
			KSE::Data::SetGUIData(-1, 'PT_MEMBER2');
			
			$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->LabFrame(-label=>'Current Party', -labelside=>'acrosstop', -height=>25, -width=>150)->pack(-side=>'bottom', -anchor=>'n', -pady=>40);
			
			$self->{'GUI'}{'Frame_Current1'} = $self->{'GUI'}{'Frame'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -padx=>5);
			$self->{'GUI'}{'Frame_Current2'} = $self->{'GUI'}{'Frame'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -padx=>5);
			
			$self->{'GUI'}{'Frame_Current1'}->Label(-text=>'Party Member 1: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -expand=>1, -padx=>5);
			$self->{'GUI'}{'Frame_Current1_Base'} = $self->{'GUI'}{'Frame_Current1'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -fill=>'x', -expand=>1, -padx=>5);
			$self->{'GUI'}{'Frame_Current1_1'} = $self->{'GUI'}{'Frame_Current1_Base'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -pady=>5, -padx=>5);
#			$self->{'GUI'}{'Frame_Current1_2'} = $self->{'GUI'}{'Frame_Current1_Base'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -pady=>5, -padx=>5);
			
			$self->{'gflag'} = -1;
			$self->{'GUI'}{'Frame_Current1_1'}->Radiobutton(-text=>'None', -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER1'), -command=>sub { KSE::Data::SetData('PT_MEMBER1', KSE::Data::GetGUIData('PT_MEMBER1')); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
			foreach my $name (KSE::Functions::NPC::GetNPCNames())
			{
#				if($npc1_count > 4) { $npc1_frame = 2; }
				if($npc1_count > 4) { $npc1_frame = 1; }
				else                { $npc1_frame = 1; }
				$self->{'gflag'} = KSE::Functions::NPC::GetNPCIndex($name);
				$self->{'GUI'}{'Frame_Current1_' . $npc1_frame}->Radiobutton(-text=>$name, -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER1'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('PT_MEMBER1'), 'PT_MEMBER1'); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
				$npc1_count++;
			}
			
			$self->{'gflag'} = -1;
			
			$self->{'GUI'}{'Frame_Current2'}->Label(-text=>'Party Member 2: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -expand=>1, -padx=>5);
			$self->{'GUI'}{'Frame_Current2_Base'} = $self->{'GUI'}{'Frame_Current2'}->Frame(-height=>30, -width=>150)->pack(-side=>'left', -fill=>'x', -expand=>1, -padx=>5);
			$self->{'GUI'}{'Frame_Current2_1'} = $self->{'GUI'}{'Frame_Current2_Base'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -pady=>5, -padx=>5);
#			$self->{'GUI'}{'Frame_Current2_2'} = $self->{'GUI'}{'Frame_Current2_Base'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -expand=>1, -pady=>5, -padx=>5);

			$self->{'GUI'}{'Frame_Current2_1'}->Radiobutton(-text=>'None', -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER2'), -command=>sub { KSE::Data::SetData('PT_MEMBER2', KSE::Data::GetGUIData('PT_MEMBER2')); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
			foreach my $name (KSE::Functions::NPC::GetNPCNames())
			{
#				if($npc2_count > 4) { $npc2_frame = 2; }
				if($npc2_count > 4) { $npc2_frame = 1; }
				else                { $npc2_frame = 1; }
				$self->{'gflag'} = KSE::Functions::NPC::GetNPCIndex($name);
				$self->{'GUI'}{'Frame_Current2_' . $npc2_frame}->Radiobutton(-text=>$name, -value=>$self->{'gflag'}, -variable=>KSE::Data::GetGUIDataRef('PT_MEMBER2'), -command=>sub { KSE::Data::SetData('None', KSE::Data::GetGUIData('PT_MEMBER2'), 'PT_MEMBER2'); })->pack(-side=>'left', -anchor=>'w', -expand=>1, -fill=>'x');
				$npc2_count++;
			}
			
			$gflag = -1;
		}
	}
}

sub AddPartyMembers
{
	my ($game, @members) = @_;
	
	my $npc_count = -1;
	foreach my $npc_name (@members)
	{
		$npc_count++;
		
		$self->{'GUI'}{'Frame_Current1_P' . $npc_count} = $self->{'GUI'}{'Frame_Current1'}->Radiobutton(-text=>$npc_name, -value=>KSE::Functions::NPC::GetNPCIndex($npc_name), -variable=>\$self->{'Data'}{'Party1'})->pack(-side=>'left', -anchor=>'w');
		
		$self->{'GUI'}{'Frame_Current2_P' . $npc_count} = $self->{'GUI'}{'Frame_Current2'}->Radiobutton(-text=>$npc_name, -value=>KSE::Functions::NPC::GetNPCIndex($npc_name), -variable=>\$self->{'Data'}{'Party1'})->pack(-side=>'left', -anchor=>'w');
	}
}

sub RemovePartyMembers
{
	$self->{'GUI'}{'Frame_Current1_P1'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P2'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P3'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P4'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P5'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P6'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P7'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P8'}->destroy;
	$self->{'GUI'}{'Frame_Current1_P9'}->destroy;
	
	$self->{'GUI'}{'Frame_Current2_P1'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P2'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P3'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P4'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P5'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P6'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P7'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P8'}->destroy;
	$self->{'GUI'}{'Frame_Current2_P9'}->destroy;
	
	if(Exists($self->{'GUI'}{'Frame_Current1_P10'})) { $self->{'GUI'}{'Frame_Current1_P10'}->destroy; }
	if(Exists($self->{'GUI'}{'Frame_Current2_P10'})) { $self->{'GUI'}{'Frame_Current2_P10'}->destroy; }
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