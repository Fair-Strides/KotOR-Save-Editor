#line 1 "KSE/GUI/Powers.pm"
package KSE::GUI::Powers;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Functions::Powers;

use MIME::Base64 qw(encode_base64);

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::RadioButton;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $game = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'} = 'Player';
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
	
	$self->{'Data'}{$piece} = $data;
}

sub Create
{
	my ($self, $parent) = @_;
	
	$self->{'GUI'}{'Parent'}	= $parent;
	
#	$self->{'GUI'}{'TargetSelection'} = KSE::GUI::Classes->new($game);
#	$self->{'GUI'}{'TargetSelection'}->CreateClassDropdown($parent, 'Powers');
	
	KSE::GUI::Main::SetResourceStep('Creating power info frame.');
	# Info Frame
	$self->{'GUI'}{'Frame1'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	
	# Power Frame
	$self->{'GUI'}{'Frame2'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	KSE::GUI::Main::SetResourceProgress(5);
	
	KSE::GUI::Main::SetResourceStep('Creating power table.');
	# Power GUI
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame1'}->Scrolled('HList', -scrollbars=>'osoe', -columns=>4, -drawbranch=>0, -header=>1, -height=>30, -indicator=>1, -itemtype=>'text', -selectborderwidth=>0, -separator=>'#', -width=>80, -browsecmd=>[\&ShowPowerInfo, $self])->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	$self->{'GUI'}{'List'}->columnWidth(0, '-char', 10);
	$self->{'GUI'}{'List'}->columnWidth(1, '-char', 15);
	$self->{'GUI'}{'List'}->columnWidth(2, '-char', 15);
	$self->{'GUI'}{'List'}->columnWidth(3, '-char', 36);
	
#	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button0);
	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'text', -borderwidth=>-2, -text=>'Select');
	$self->{'GUI'}{'List'}->headerCreate(1, -itemtype=>'text', -borderwidth=>-2, -text=>'Has Power?');
	$self->{'GUI'}{'List'}->headerCreate(2, -itemtype=>'text', -borderwidth=>-2, -text=>'Icon');
	$self->{'GUI'}{'List'}->headerCreate(3, -itemtype=>'text', -borderwidth=>-2, -text=>'Name');
	
	$self->{'GUI'}{'ButtonFrame'} = $self->{'GUI'}{'Frame2'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -padx=>15, -pady=>10);
	$self->{'GUI'}{'ButtonFrame'}->Button(-text=>'Add Powers', -command=>sub { AddPowers($self); })->pack(-side=>'left', -padx=>5);
	$self->{'GUI'}{'ButtonFrame'}->Button(-text=>'Remove Powers', -command=>sub { AddPowers($self); })->pack(-side=>'left', -padx=>5);
	
	KSE::GUI::Main::SetResourceProgress(20);
	KSE::GUI::Main::SetResourceStep('Populating power table.');

	# Info GUI
	$self->{'GUI'}{'Info'}	= $self->{'GUI'}{'Frame2'}->ROText(-wrap=>'word', -font=>[-size=>12], -background=>'SystemButtonFace', -height=>30, -width=>120, -relief=>'flat', -state=>'disabled')->pack(-fill=>'both', -padx=>5, -pady=>5);

	$self->{'GUI'}{'ListPicImager'} = Imager->new();
	KSE::Functions::Powers::FillPowers($self);
}

sub ChangePowersExternal
{
	my ($self, $target) = @_;
	
#	print "Old Self: " . KSE::GUI::Target::GetTarget() . "\n";
	$self->{'Type'} = $target;
#	print "New Self: " . $self->{'Type'} . "\n";
	
#	$self->{'GUI'}{'TargetSelection'}->{'Type'} = $target;
#	$self->{'GUI'}{'TargetSelection'}->UpdateClassDropdown();
	
	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
	{
#		$self->{'Data'}{$entry} = KSE::Functions::GetHasPower($self, $self->{'GUI'}{'List'}->info('data', $entry));
		my $value = KSE::Functions::Powers::GetHasPower(KSE::GUI::Target::GetTarget(), $self->{'GUI'}{'List'}->info('data', $entry));
		
		if($value == 1)	{ $value = 'Yes';	}
		else			{ $value = 'No';	}
		
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, '-text', $value);
	}
}

sub ChangeTarget
{
	my $target = shift;
	my $self = KSE::GUI::Main::GetPanelSelf('Powers');
	
#	print "Old Self: " . KSE::GUI::Target::GetTarget() . "\n";
	$self->{'Type'} = $target;
#	print "New Self: " . $self->{'Type'} . "\n";
	
#	$self->{'GUI'}{'TargetSelection'}->{'Type'} = $target;
#	$self->{'GUI'}{'TargetSelection'}->UpdateClassDropdown();
	
	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
	{
#		$self->{'Data'}{$entry} = KSE::Functions::GetHasPower($self, $self->{'GUI'}{'List'}->info('data', $entry));
		my $value = KSE::Functions::Powers::GetHasPower(KSE::GUI::Target::GetTarget(), $self->{'GUI'}{'List'}->info('data', $entry));
		
		if($value == 1)	{ $value = 'Yes';	}
		else			{ $value = 'No';	}
		
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, '-text', $value);
	}
}

sub PopulatePowers
{
	my ($self, $image, $name, $value, $index) = @_;
	
	if($value == 1)	{ $value = 'Yes';	}
	else			{ $value = 'No';	}
	
	$self->{'GUI'}{'ListPicImager'}->read(file=>$image, type=>'tga');
	$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
	$self->{'GUI'}{'ListPic' . $index} = $self->{'GUI'}{'List'}->Photo(-data=>encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png');

	$self->{'Data'}{$index} = $value;
	$self->{'GUI'}{'Check_' . $index} = $self->{'GUI'}{'List'}->Checkbutton(-onvalue=>1, -offvalue=>0, -indicatoron=>1, -variable=>\$self->{'Data'}{$index});
	
	$self->{'GUI'}{'List'}->add($index, -data=>$index);
	$self->{'GUI'}{'List'}->itemCreate($index, 0, -itemtype=>'window', -widget=>$self->{'GUI'}{'Check_' . $index});
	$self->{'GUI'}{'List'}->itemCreate($index, 1, -itemtype=>'text', -text=>$value);
	$self->{'GUI'}{'List'}->itemCreate($index, 2, -itemtype=>'imagetext', -image=>$self->{'GUI'}{'ListPic' . $index}, -showimage=>1, -showtext=>0);
	$self->{'GUI'}{'List'}->itemCreate($index, 3, -text=>$name);
}

sub ShowPowerInfo
{
	my $self = shift;
	
	my $entry = $self->{'GUI'}{'List'}->info('anchor');
	my $Power = $self->{'GUI'}{'List'}->info('data', $entry);
	
	$self->{'GUI'}{'Info'}->configure(-state=>'normal');
	$self->{'GUI'}{'Info'}->Contents(KSE::Functions::Powers::GetDescription($Power));
	$self->{'GUI'}{'Info'}->configure(-state=>'disabled');
}

sub AddPowers
{
	my $self = shift;
	
	foreach my $Power (keys %{$self->{'Data'}})
	{
		if($self->{'Data'}{$Power} == 1)
		{
			KSE::Functions::Powers::AddPower(KSE::GUI::Target::GetTarget(), $Power);
			$self->{'Data'}{$Power} = 0;
			$self->{'GUI'}{'List'}->itemConfigure($Power, 1, '-text', 'Yes');
		}
	}
	
#	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
#	{
#		my $check = $self->{'GUI'}{'List'}->itemcget($entry, 0, '-widget');
#		
}

sub RemovePowers
{
	my $self = shift;
	
	foreach my $Power (keys %{$self->{'Data'}})
	{
		if($self->{'Data'}{$Power} == 1)
		{
			KSE::Functions::Powers::RemovePower(KSE::GUI::Target::GetTarget(), $Power);
			$self->{'Data'}{$Power} = 0;
			$self->{'GUI'}{'List'}->itemConfigure($Power, 1, '-text', 'No');
		}
	}
	
#	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
#	{
#		my $check = $self->{'GUI'}{'List'}->itemcget($entry, 0, '-widget');
#		
}

sub Destroy
{
	my $self = shift;
	foreach ($self->{'GUI'}->children)
	{
		$_->destroy;
	}
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