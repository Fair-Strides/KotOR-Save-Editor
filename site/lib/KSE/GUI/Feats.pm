#line 1 "KSE/GUI/Feats.pm"
package KSE::GUI::Feats;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Functions::Feats;

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
	
	KSE::GUI::Main::SetResourceStep('Creating feat info frame.');
	# Info Frame
	$self->{'GUI'}{'Frame1'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	
	# Feat Frame
	$self->{'GUI'}{'Frame2'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	KSE::GUI::Main::SetResourceProgress(5);
	
	KSE::GUI::Main::SetResourceStep('Creating feat table.');
	# Feat GUI
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame1'}->Scrolled('HList', -scrollbars=>'osoe', -columns=>4, -drawbranch=>0, -header=>1, -height=>30, -indicator=>1, -itemtype=>'text', -selectborderwidth=>0, -separator=>'#', -width=>80, -browsecmd=>[\&ShowFeatInfo, $self])->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	$self->{'GUI'}{'List'}->columnWidth(0, '-char', 10);
	$self->{'GUI'}{'List'}->columnWidth(1, '-char', 15);
	$self->{'GUI'}{'List'}->columnWidth(2, '-char', 15);
	$self->{'GUI'}{'List'}->columnWidth(3, '-char', 36);
	
#	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button0);
	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'text', -borderwidth=>-2, -text=>'Select');
	$self->{'GUI'}{'List'}->headerCreate(1, -itemtype=>'text', -borderwidth=>-2, -text=>'Has Feat?');
	$self->{'GUI'}{'List'}->headerCreate(2, -itemtype=>'text', -borderwidth=>-2, -text=>'Icon');
	$self->{'GUI'}{'List'}->headerCreate(3, -itemtype=>'text', -borderwidth=>-2, -text=>'Name');
	
	$self->{'GUI'}{'ButtonFrame'} = $self->{'GUI'}{'Frame2'}->Frame(-height=>30, -width=>150)->pack(-fill=>'x', -padx=>15, -pady=>10);
	$self->{'GUI'}{'ButtonFrame'}->Button(-text=>'Add Feats', -command=>sub { AddFeats($self); })->pack(-side=>'left', -padx=>5);
	$self->{'GUI'}{'ButtonFrame'}->Button(-text=>'Remove Feats', -command=>sub { RemoveFeats($self); })->pack(-side=>'left', -padx=>5);
	
	KSE::GUI::Main::SetResourceProgress(20);
	KSE::GUI::Main::SetResourceStep('Populating feat table.');
	
	# Info GUI
	$self->{'GUI'}{'Info'}	= $self->{'GUI'}{'Frame2'}->ROText(-font=>[-size=>12], -wrap=>'word', -background=>'SystemButtonFace', -height=>30, -width=>120, -relief=>'flat', -state=>'disabled')->pack(-fill=>'both', -padx=>5, -pady=>5);
	
	$self->{'GUI'}{'ListPicImager'} = Imager->new();
	KSE::Functions::Feats::FillFeats($self);
}

sub ChangeFeatsExternal
{
	my ($self, $target) = @_;
	
	$self->{'Type'} = $target;
	
#	print "Target: $target\n";
	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
	{
#		$self->{'Data'}{$entry} = KSE::Functions::GetHasFeat($self, $self->{'GUI'}{'List'}->info('data', $entry));
		my $value = KSE::Functions::Feats::GetHasFeat($target, $entry);
		
#		print "Value of $entry is $value\n";
		if($value == 1)	{ $value = 'Yes';	}
		else			{ $value = 'No';	}
		
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, '-text', $value);
	}
}

sub ChangeTarget
{
	my $target = shift;
	my $self = KSE::GUI::Main::GetPanelSelf('Feats');
	
	$self->{'Type'} = $target;
	
#	print "Target: $target\n";
	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
	{
#		$self->{'Data'}{$entry} = KSE::Functions::GetHasFeat($self, $self->{'GUI'}{'List'}->info('data', $entry));
		my $value = KSE::Functions::Feats::GetHasFeat($target, $entry);
		
#		print "Value of $entry is $value\n";
		if($value == 1)	{ $value = 'Yes';	}
		else			{ $value = 'No';	}
		
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, '-text', $value);
	}
}

sub PopulateFeats
{
	my ($self, $image, $name, $value, $index) = @_;
	
	if($value == 1)	{ $value = 'Yes';	}
	else			{ $value = 'No';	}
	
	$self->{'GUI'}{'ListPicImager'}->read(file=>$image, type=>'tga');
	$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
	$self->{'GUI'}{'ListPic' . $name . $index} = $self->{'GUI'}{'List'}->Photo(-data=>encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png');

	$self->{'Data'}{$index} = 0;
	$self->{'GUI'}{'Check_' . $name . $index} = $self->{'GUI'}{'List'}->Checkbutton(-onvalue=>1, -offvalue=>0, -height=>2, -indicatoron=>1, -variable=>\$self->{'Data'}{$index});
	
	$self->{'GUI'}{'List'}->add($index, -data=>$index);
	$self->{'GUI'}{'List'}->itemCreate($index, 0, -itemtype=>'window', -widget=>$self->{'GUI'}{'Check_' . $name . $index});
	$self->{'GUI'}{'List'}->itemCreate($index, 1, -itemtype=>'text', -text=>$value);
	$self->{'GUI'}{'List'}->itemCreate($index, 2, -itemtype=>'imagetext', -image=>$self->{'GUI'}{'ListPic' . $name . $index}, -showimage=>1, -showtext=>0);
	$self->{'GUI'}{'List'}->itemCreate($index, 3, -text=>$name);
}

sub ShowFeatInfo
{
	my $self = shift;
	
	my $entry = $self->{'GUI'}{'List'}->info('anchor');
	my $feat = $self->{'GUI'}{'List'}->info('data', $entry);
	
	$self->{'GUI'}{'Info'}->configure(-state=>'normal');
	$self->{'GUI'}{'Info'}->Contents(KSE::Functions::Feats::GetDescription($feat));
	$self->{'GUI'}{'Info'}->configure(-state=>'disabled');
}

sub AddFeats
{
	my $self = shift;
	
	foreach my $feat (keys %{$self->{'Data'}})
	{
		if($self->{'Data'}{$feat} == 1)
		{
			KSE::Functions::Feats::AddFeat(KSE::GUI::Target::GetTarget(), $feat);
			$self->{'Data'}{$feat} = 0;
			$self->{'GUI'}{'List'}->itemConfigure($feat, 1, '-text', 'Yes');
		}
	}
	
#	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
#	{
#		my $check = $self->{'GUI'}{'List'}->itemcget($entry, 0, '-widget');
#		
}

sub RemoveFeats
{
	my $self = shift;
	
	foreach my $feat (keys %{$self->{'Data'}})
	{
		if($self->{'Data'}{$feat} == 1)
		{
			KSE::Functions::Feats::RemoveFeat(KSE::GUI::Target::GetTarget(), $feat);
			$self->{'Data'}{$feat} = 0;
			$self->{'GUI'}{'List'}->itemConfigure($feat, 1, '-text', 'No');
		}
	}
	
#	foreach my $entry ($self->{'GUI'}{'List'}->info('children'))
#	{
#		my $check = $self->{'GUI'}{'List'}->itemcget($entry, 0, '-widget');
#		
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