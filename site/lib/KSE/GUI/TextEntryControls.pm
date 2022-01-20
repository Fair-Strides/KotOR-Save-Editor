#line 1 "KSE/GUI/TextEntryControls.pm"
package KSE::GUI::TextEntryControls; #SaveGameName, Area, LastModule, FirstName

use KSE::Data;

use Tk;
use Tk::LabFrame;
use Tk::Label;
use Tk::Entry;

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

sub ExportData
{
	my $self = shift;
	
	return $self;
}

sub ChangeTarget
{
	my ($self, @pieces) = @_;
	
	foreach my $piece (@pieces)
	{
		if($piece eq 'FirstName')
		{
#			$self->{'Data'}{$piece} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), $piece);
			KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), $piece), $piece);
		}
		else
		{
#			$self->{'Data'}{$piece} = KSE::Functions::Saves::GetSaveData($piece);
#			print "Grabbing " . uc($piece) . ": " . KSE::Data::GetData('None', uc $piece) . "\n";
			KSE::Data::SetGUIData(KSE::Data::GetData('None', uc $piece), uc $piece);
		}
	}
}

sub Create
{
	my ($self, $parent, @controls) = @_;
	
	$self->{'GUI'}{'Parent'} = $parent;
		
	foreach my $control (@controls)
	{
		if($control eq 'SaveGameName')
		{
#			$self->{'Data'}{$control} = KSE::Functions::Saves::GetSaveData('SAVEGAMENAME');
			KSE::Data::SetGUIData('', uc $control);

			$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->LabFrame(-label=>'Name', -labelside=>'acrosstop', -height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');

			$self->{'GUI'}{'Frame_SaveGameName'} = $self->{'GUI'}{'Frame'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_SaveGameName'}->Label(-text=>'Save Game Name: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_SaveGameName'}->Entry(-textvariable=>KSE::Data::GetGUIDataRef('SAVEGAMENAME'), -width=>20, -validate=>'key', -validatecommand=>sub { my $value = $_[0]; KSE::Functions::Saves::SetSaveData($value, 'SAVEGAMENAME'); return 1; } )->pack(-side=>'right', -padx=>5, -fill=>'x');
		}
		elsif($control eq 'Area')
		{
			KSE::Data::SetGUIData('', uc $control);
			$self->{'GUI'}{'Frame_Area'} = $self->{'GUI'}{'Frame'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_Area'}->Label(-text=>'Area Name: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_Area'}->Label(-textvariable=>KSE::Data::GetGUIDataRef('AREANAME'), -width=>20)->pack(-side=>'right', -padx=>5, -fill=>'x');			
		}
		elsif($control eq 'LastModule')
		{
			KSE::Data::SetGUIData('', uc $control);
			$self->{'GUI'}{'Frame_LastModule'} = $self->{'GUI'}{'Frame'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_LastModule'}->Label(-text=>'Last Area Name: ', -width=>15, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_LastModule'}->Label(-textvariable=>KSE::Data::GetGUIDataRef('LASTMODULE'), -width=>20)->pack(-side=>'right', -padx=>5, -fill=>'x');
		}
		else # It's the FirstName
		{
			KSE::Data::SetGUIData('', $control);
			$self->{'GUI'}{'Frame_FirstName'} = $self->{'GUI'}{'Parent'}->Frame(-height=>30, -width=>150)->pack(-side=>'top', -fill=>'x', -pady=>10, -padx=>5);
			$self->{'GUI'}{'Frame_FirstName'}->Label(-text=>'First Name: ', -width=>10, -anchor=>'w', -justify=>'left')->pack(-side=>'left', -padx=>5);
			$self->{'GUI'}{'Frame_FirstName'}->Entry(-textvariable=>KSE::Data::GetGUIDataRef($control), -width=>20, -validate=>'key', -validatecommand=>sub { my $value = $_[0]; KSE::Functions::Saves::SetSaveData($value, KSE::GUI::Target::GetTarget(), 'FirstName'); return 1; } )->pack(-side=>'left', -padx=>15, -fill=>'x');
		}
	}
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