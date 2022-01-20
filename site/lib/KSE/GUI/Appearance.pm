#line 1 "KSE/GUI/Appearance.pm"
package KSE::GUI::Appearance;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Data;
use KSE::Functions::Appearance;

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	my $game = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'} = $type;
	$self->{'Game'} = $game;
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
	
#	$self->{'Data'}{$piece} = $data;
	KSE::Data::SetGUIData($data, 'Appearance', $piece);
	
	if($piece eq 'Row')	{ $self->RefreshAppearance(); }
}

sub ExportData
{
	my $self = shift;
	
	return $self;
}

sub ChangeTarget
{
	my ($self, $target) = @_;
	$self->{'Type'} = $target;
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Appearance_Type');
#	$self->{'Data'}{'Label'} = $self->{'Data'}{'Row'} . ' - ' . KSE::Functions::Soundset::GetLabel($self->{'Data'}{'Row'});

	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'Appearance_Type'), 'Appearance', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Appearance', 'Row') . ' - ' . KSE::Functions::Appearance::GetLabel(KSE::Data::GetGUIData('Appearance', 'Row')), 'Appearance', 'Label');
	
	if($target ne 'Player')
	{
		$self->{'GUI'}{'Spacer'}->configure(-height=>20);
	}
	else
	{
		$self->{'GUI'}{'Spacer'}->configure(-height=>60);
	}
	
	$self->RefreshAppearance();
}

sub Create
{
	my ($self, $parent) = @_;
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'Appearance_Type');
#	$self->{'Data'}{'Label'} = $self->{'Data'}{'Row'} . ' - ' . KSE::Functions::Soundset::GetLabel($self->{'Data'}{'Row'});
	
	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'Appearance_Type'), 'Appearance', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Appearance', 'Row') . ' - ' . KSE::Functions::Appearance::GetLabel(KSE::Data::GetGUIData('Appearance', 'Row')), 'Appearance', 'Label');
	
	$self->{'GUI'}{'Parent'}	= $parent;
	
	my $spacer_height = 85;
	if($self->{'Game'} == 2 && KSE::GUI::Target::GetTarget() ne 'Player') { $spacer_height = 45; }
	
	$self->{'GUI'}{'Frame_Base'} = $self->{'GUI'}{'Parent'}->Frame(-height=>60, -width=>150)->pack(-fill=>'x');
	$self->{'GUI'}{'Spacer'}	= $self->{'GUI'}{'Frame_Base'}->Frame(-height=>$spacer_height, -width=>150)->pack(-fill=>'x');
	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Frame_Base'}->LabFrame(-label=>'Appearance', -labelside=>'acrosstop', -height=>25, -width=>150)->pack(-side=>'top', -anchor=>'nw');
	
#	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'Appearance: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; $self->{'Data'}{'Row'} = $data; KSE::Functions::Appearance::ChangeAppearance($self); $self->RefreshAppearance(); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>\$self->{'Data'}{'Label'})->pack(-fill=>'x', -padx=>10, -pady=>5);
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'Appearance: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; KSE::Data::SetGUIData($data, 'Appearance', 'Row'); KSE::Functions::Appearance::ChangeAppearance($self); $self->RefreshAppearance(); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>KSE::Data::GetGUIDataRef('Appearance', 'Label'))->pack(-fill=>'x', -padx=>10, -pady=>5);
	
##	$self->{'GUI'}{'Row'} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
##	$self->{'GUI'}{'Row'}->Label(-text=>'Row Number: ')->pack(-side=>'left', -padx=>5);
##	$self->{'GUI'}{'Row'}->Label(-textvariable=>\$self->{'Data'}{'Row'})->pack(-side=>'right', -padx=>5);

	if(KSE::Data::GetData('None', 'Game') == 1)
	{
#		$self->{'Data'}{'Models'}{'Underwear'}			= '';
#		$self->{'Data'}{'Models'}{'Clothing'}			= '';
#		$self->{'Data'}{'Models'}{'Light Armor 1'}		= '';
#		$self->{'Data'}{'Models'}{'Light Armor 2'}		= '';
#		$self->{'Data'}{'Models'}{'Medium Armor 1'}		= '';
#		$self->{'Data'}{'Models'}{'Medium Armor 2'}		= '';
#		$self->{'Data'}{'Models'}{'Heavy Armor 1'}		= '';
#		$self->{'Data'}{'Models'}{'Heavy Armor 2'}		= '';
#		$self->{'Data'}{'Models'}{'Robes'}				= '';
#		$self->{'Data'}{'Models'}{'Revan Armor'}		= '';
	
		my ($model, $number) = (undef, 0);
		foreach $model ('Underwear', 'Clothing', 'Light Armor 1', 'Light Armor 2', 'Medium Armor 1', 'Medium Armor 2', 'Heavy Armor 1', 'Heavy Armor 2', 'Robes', 'Revan Armor')
		{
			$number++;
			KSE::Data::SetGUIData('', 'Appearance', 'Models', $model);
			
			$self->{'GUI'}{'Model' . $number} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Model' . $number}->Label(-text=>$model)->pack(-side=>'left', -padx=>5);
#			$self->{'GUI'}{'Model' . $number}->Label(-textvariable=>\$self->{'Data'}{'Models'}{$model})->pack(-side=>'right', -padx=>5);
			$self->{'GUI'}{'Model' . $number}->Label(-textvariable=>KSE::Data::GetGUIDataRef('Appearance', 'Models', $model))->pack(-side=>'right', -padx=>5);
		}
	}
	else
	{
#		$self->{'Data'}{'Models'}{'Underwear'}				= '';
#		$self->{'Data'}{'Models'}{'Clothing'}				= '';
#		$self->{'Data'}{'Models'}{'Light Armor 1'}			= '';
#		$self->{'Data'}{'Models'}{'Light Armor 2'}			= '';
#		$self->{'Data'}{'Models'}{'Medium Armor 1'}			= '';
#		$self->{'Data'}{'Models'}{'Medium Armor 2'}			= '';
#		$self->{'Data'}{'Models'}{'Heavy Armor 1'}			= '';
#		$self->{'Data'}{'Models'}{'Heavy Armor 2'}			= '';
#		$self->{'Data'}{'Models'}{'Basic Robes'}			= '';
#		$self->{'Data'}{'Models'}{'Revan Armor'}			= '';
#		$self->{'Data'}{'Models'}{'Flight Suit'}			= '';
#		$self->{'Data'}{'Models'}{'Dancer\'s Outfit'}		= '';
#		$self->{'Data'}{'Models'}{'Sha Armors'}				= '';
#		$self->{'Data'}{'Models'}{'Knight/Master Robes'}	= '';
		
		my ($model, $number) = (undef, 0);
		foreach $model ('Underwear', 'Clothing', 'Light Armor 1', 'Light Armor 2', 'Medium Armor 1', 'Medium Armor 2', 'Heavy Armor 1', 'Heavy Armor 2', 'Basic Robes', 'Revan Armor', 'Flight Suit', 'Dancer\'s Outfit', 'Sha Armors', 'Knight/Master Robes')
		{
			$number++;
			KSE::Data::SetGUIData('', 'Appearance', 'Models', $model);
			
			$self->{'GUI'}{'Model' . $number} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);
			$self->{'GUI'}{'Model' . $number}->Label(-text=>$model)->pack(-side=>'left', -padx=>5);
#			$self->{'GUI'}{'Model' . $number}->Label(-textvariable=>\$self->{'Data'}{'Models'}{$model})->pack(-side=>'right', -padx=>5);
			$self->{'GUI'}{'Model' . $number}->Label(-textvariable=>KSE::Data::GetGUIDataRef('Appearance', 'Models', $model))->pack(-side=>'right', -padx=>5);
		}
	}
	
	$self->RefreshAppearance();
	$self->FillList();
}

# sub RefreshAppearance
# {
	# my $self = shift;
	# my $row = $self->{'Data'}->{'Row'};
	#
	# if($self->{'Game'} == 1)
	# {
		# $self->{'Data'}{'Models'}{'Underwear'}			= KSE::Functions::Appearance::GetModel($row, 'A');
		# $self->{'Data'}{'Models'}{'Clothing'}			= KSE::Functions::Appearance::GetModel($row, 'B');
		# $self->{'Data'}{'Models'}{'Light Armor 1'}		= KSE::Functions::Appearance::GetModel($row, 'C');
		# $self->{'Data'}{'Models'}{'Light Armor 2'}		= KSE::Functions::Appearance::GetModel($row, 'D');
		# $self->{'Data'}{'Models'}{'Medium Armor 1'}		= KSE::Functions::Appearance::GetModel($row, 'E');
		# $self->{'Data'}{'Models'}{'Medium Armor 2'}		= KSE::Functions::Appearance::GetModel($row, 'F');
		# $self->{'Data'}{'Models'}{'Heavy Armor 1'}		= KSE::Functions::Appearance::GetModel($row, 'G');
		# $self->{'Data'}{'Models'}{'Heavy Armor 2'}		= KSE::Functions::Appearance::GetModel($row, 'H');
		# $self->{'Data'}{'Models'}{'Robes'}				= KSE::Functions::Appearance::GetModel($row, 'I');
		# $self->{'Data'}{'Models'}{'Revan Armor'}		= KSE::Functions::Appearance::GetModel($row, 'J');
	# }
	# else
	# {
		# $self->{'Data'}{'Models'}{'Underwear'}				= KSE::Functions::Appearance::GetModel($row, 'A');
		# $self->{'Data'}{'Models'}{'Clothing'}				= KSE::Functions::Appearance::GetModel($row, 'B');
		# $self->{'Data'}{'Models'}{'Light Armor 1'}			= KSE::Functions::Appearance::GetModel($row, 'C');
		# $self->{'Data'}{'Models'}{'Light Armor 2'}			= KSE::Functions::Appearance::GetModel($row, 'D');
		# $self->{'Data'}{'Models'}{'Medium Armor 1'}			= KSE::Functions::Appearance::GetModel($row, 'E');
		# $self->{'Data'}{'Models'}{'Medium Armor 2'}			= KSE::Functions::Appearance::GetModel($row, 'F');
		# $self->{'Data'}{'Models'}{'Heavy Armor 1'}			= KSE::Functions::Appearance::GetModel($row, 'G');
		# $self->{'Data'}{'Models'}{'Heavy Armor 2'}			= KSE::Functions::Appearance::GetModel($row, 'H');
		# $self->{'Data'}{'Models'}{'Basic Robes'}			= KSE::Functions::Appearance::GetModel($row, 'I');
		# $self->{'Data'}{'Models'}{'Revan Armor'}			= KSE::Functions::Appearance::GetModel($row, 'J');
		# $self->{'Data'}{'Models'}{'Flight Suit'}			= KSE::Functions::Appearance::GetModel($row, 'K');
		# $self->{'Data'}{'Models'}{'Dancer\'s Outfit'}		= KSE::Functions::Appearance::GetModel($row, 'L');
		# $self->{'Data'}{'Models'}{'Sha Armors'}				= KSE::Functions::Appearance::GetModel($row, 'M');
		# $self->{'Data'}{'Models'}{'Knight/Master Robes'}	= KSE::Functions::Appearance::GetModel($row, 'N');
	# }
# }

sub RefreshAppearance
{
	my $self = shift;
	my $row = KSE::Data::GetGUIData('Appearance', 'Row');
	
#	print "Row is $row.\nBefore:\n";
#	foreach my $model ('Underwear', 'Clothing', 'Light Armor 1', 'Light Armor 2', 'Medium Armor 1', 'Medium Armor 2', 'Heavy Armor 1', 'Heavy Armor 2', 'Robes', 'Revan Armor')
#	{
#		print "\tSlot $model: " . KSE::Data::GetGUIData('Appearance', 'Models', $model) . ".\n";
#	}

	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'A'), 'Appearance', 'Models', 'Underwear');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'B'), 'Appearance', 'Models', 'Clothing');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'C'), 'Appearance', 'Models', 'Light Armor 1');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'D'), 'Appearance', 'Models', 'Light Armor 2');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'E'), 'Appearance', 'Models', 'Medium Armor 1');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'F'), 'Appearance', 'Models', 'Medium Armor 2');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'G'), 'Appearance', 'Models', 'Heavy Armor 1');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'H'), 'Appearance', 'Models', 'Heavy Armor 2');
	KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'J'), 'Appearance', 'Models', 'Revan Armor');
	
#	print "After:\n";
#	foreach my $model ('Underwear', 'Clothing', 'Light Armor 1', 'Light Armor 2', 'Medium Armor 1', 'Medium Armor 2', 'Heavy Armor 1', 'Heavy Armor 2', 'Robes', 'Revan Armor')
#	{
#		print "\tSlot $model: " . KSE::Data::GetGUIData('Appearance', 'Models', $model) . ".\n";
#	}
	
	if(KSE::Data::GetData('None', 'Game') == 2)
	{
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'I'), 'Appearance', 'Models', 'Basic Robes');
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'K'), 'Appearance', 'Models', 'Flight Suit');
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'L'), 'Appearance', 'Models', 'Dancer\'s Outfit');
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'M'), 'Appearance', 'Models', 'Sha Armors');
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'N'), 'Appearance', 'Models', 'Knight/Master Robes');
	}
	else
	{
		KSE::Data::SetGUIData(KSE::Functions::Appearance::GetModel($row, 'I'), 'Appearance', 'Models', 'Robes');
	}
}

sub FillList
{
	my $self = shift;

	my @list = KSE::Functions::Appearance::GetRowLabels();
	$self->ClearList();
	
	my $count = -1;
	foreach my $choice (@list)
	{
		$count++;
		$self->{'GUI'}{'List'}->insert('end', $count . ' - ' . $choice);
	}
}

sub ClearList
{
	my $self = shift;

	$self->{'GUI'}{'List'}->delete(0, 'end');
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