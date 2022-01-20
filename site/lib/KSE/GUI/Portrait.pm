#line 1 "KSE/GUI/Portrait.pm"
package KSE::GUI::Portrait;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use Imager;

use MIME::Base64 qw(encode_base64);

use KSE::Data;

use KSE::Functions::Main;

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::Photo;
use Tk::PNG;

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
	
	$self->{'Data'}{$piece} = $data;
	
	if($piece eq 'Row')	{ $self->RefreshPortraits(); }
}

sub ChangeTarget
{
	my ($self, $target) = @_;
	$self->{'Type'} = $target;
	
	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'PortraitId'), 'Portrait', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Portrait', 'Row') . ' - ' . KSE::Functions::Portrait::GetLabel(KSE::Data::GetGUIData('Portrait', 'Row')), 'Portrait', 'Label');
	
	$self->RefreshPortraits();
}

sub Create
{
	my ($self, $parent) = @_;
	
#	$self->{'Data'}{'Row'} = KSE::Functions::Saves::GetSaveData(KSE::GUI::Target::GetTarget(), 'PortraitId');
#	$self->{'Data'}{'Label'} = $self->{'Data'}{'Row'} . ' - ' . KSE::Functions::Portrait::GetLabel($self->{'Data'}{'Row'});
	KSE::Data::SetGUIData(KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'PortraitId'), 'Portrait', 'Row');
	KSE::Data::SetGUIData(KSE::Data::GetGUIData('Portrait', 'Row') . ' - ' . KSE::Functions::Portrait::GetLabel(KSE::Data::GetGUIData('Portrait', 'Row')), 'Portrait', 'Label');
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}	= $self->{'GUI'}{'Parent'}->LabFrame(-label=>'Portrait', -labelside=>'acrosstop', -height=>25, -width=>200)->pack(-side=>'left', -anchor=>'ne', -ipadx=>5, -padx=>5);
	
#	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'Portrait: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; $self->{'Data'}{'Row'} = $data; KSE::Functions::Portrait::ChangePortrait($self); $self->RefreshPortraits(); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>\$self->{'Data'}{'Label'})->pack(-fill=>'x', -padx=>10, -pady=>5);
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame'}->BrowseEntry(-label=>'Portrait: ', -autolimitheight=>1, -autolistwidth=>1, -browse2cmd=>sub {my ($widget, $data) = @_; KSE::Data::SetGUIData($data, 'Portrait', 'Row'); KSE::Functions::Portrait::ChangePortrait($self); $self->RefreshPortraits(); }, -disabledbackground=>'#FFFFFF', -disabledforeground=>'#000000', -state=>'readonly', -listheight=>10, -variable=>KSE::Data::GetGUIDataRef('Portrait', 'Label'))->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	$self->{'GUI'}{'Row'} = $self->{'GUI'}{'Frame'}->Frame(-width=>200, -height=>25)->pack(-fill=>'x', -pady=>5);
	$self->{'GUI'}{'Row'}->Label(-text=>'')->pack(-side=>'left', -padx=>5);
#	$self->{'GUI'}{'Row'}->Label(-text=>'Row Number: ')->pack(-side=>'left', -padx=>5);
#	$self->{'GUI'}{'Row'}->Label(-textvariable=>\$self->{'Data'}{'Row'})->pack(-side=>'right', -padx=>5);

	$self->{'GUI'}{'PO_Frame'} = $self->{'GUI'}{'Frame'}->Frame(-width=>150, -height=>25)->pack(-fill=>'x', -pady=>5);

	foreach my $portrait ('baseresref', 'baseresrefe', 'baseresrefve', 'baseresrefvve', 'baseresrefvvve')
	{
#		print "Row: " . $self->{'Data'}{'Row'} . "\nColumn $portrait\n";
#		my $file = KSE::Functions::Portrait::GetPortraitFile($self->{'Data'}{'Row'}, $portrait);
		my $file = KSE::Functions::Portrait::GetPortraitFile(KSE::Data::GetGUIData('Portrait', 'Row'), $portrait);
#		print "File $file\n" . (split(/\//, $file))[-1] . "\n";
		
		$self->{'GUI'}{'Data' . $portrait} = Imager->new(file=>$file, type=>'tga') or die ("Can't 1: $!\n");
		
		if($self->{'Game'} == 2)
		{
			$self->{'GUI'}{'Data' . $portrait} = $self->{'GUI'}{'Data' . $portrait}->scale(scalefactor=>0.5);
		}
		
		my $data = undef;
#		my $data = (split(/\//, $file))[-1];
#		$data =~ s#tga#png#; 
#		$data = KSE::Functions::Main::GetBaseDir() . "/temp/$data";
		$self->{'GUI'}{'Data' . $portrait}->write(data=>\$data, type=>'png') or die $self->{'GUI'}{'Data' . $portrait}->errstr();
#		$self->{'GUI'}{'Data' . $portrait}->write(file=>$data, type=>'png') or die $self->{'GUI'}{'Data' . $portrait}->errstr();
		$self->{'Data'}{$portrait} = $data;
		
		$self->{'GUI'}{$portrait . 'Image'} = $self->{'GUI'}{'PO_Frame'}->Photo(-data=>encode_base64($data), -format=>'png') or die ("Can't 1: $!\n");
#		$self->{'GUI'}{$portrait . 'Image'} = $self->{'GUI'}{'PO_Frame'}->Photo(-file=>$data, -format=>'png') or die ("Can't 3: $!\n");
		$self->{'GUI'}{'PO_' . $portrait} = $self->{'GUI'}->{'PO_Frame'}->Label(-image=>$self->{'GUI'}{$portrait . 'Image'})->pack(-side=>'left');
	}
	
	$self->RefreshPortraits();
	$self->FillList();
}

sub RefreshPortraits
{
	my $self = shift;
	
	foreach my $portrait ('baseresref', 'baseresrefe', 'baseresrefve', 'baseresrefvve', 'baseresrefvvve')
	{
		my $file = KSE::Functions::Portrait::GetPortraitFile(KSE::Data::GetGUIData('Portrait', 'Row'), $portrait);
#		print "Portrait: $portrait $file\n";
		$self->{'GUI'}{'Data' . $portrait}->read(file=>$file, type=>'tga');
		
#		if($self->{'Game'} == 2)
#		{
#			$self->{'GUI'}{'Data' . $portrait} = $self->{'GUI'}{'Data' . $portrait}->scale(scalefactor=>0.5);
#		}

		$self->{'GUI'}{'Data' . $portrait} = $self->{'GUI'}{'Data' . $portrait}->scale(xpixels=>64, ypixels=>64);
		my $data = undef;
		$self->{'GUI'}{'Data' . $portrait}->write(data=>\$data, type=>'png');
		$self->{'Data'}{$portrait} = $data;
		
		$self->{'GUI'}{$portrait . 'Image'}->put(encode_base64($data), -format=>'png');
		$self->{'GUI'}{'PO_' . $portrait}->configure(-image=>$self->{'GUI'}{$portrait . 'Image'});
	}
#	print "\n";
}

sub FillList
{
	my ($self, @list) = (shift, @_);
	my @list = KSE::Functions::Portrait::GetRowLabels();
	ClearList($self);
	
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