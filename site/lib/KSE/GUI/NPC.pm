#line 1 "KSE/GUI/NPC.pm"
package KSE::GUI::NPC;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use MIME::Base64;

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
	my $coderef = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'}		= $type;
	$self->{'Game'}		= $game;
	$self->{'NPCCode'}	= $coderef;
	$self->{'Data'}		= {};
	$self->{'GUI'}		= {};
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
	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	$self->{'GUI'}{'NPCFrame1'}	= $self->{'GUI'}{'Frame'}->Frame(-height=>250, -width=>150)->pack(-fill=>'x', -pady=>10);
	$self->{'GUI'}{'NPCFrame2'}	= $self->{'GUI'}{'Frame'}->Frame(-height=>250, -width=>150)->pack(-fill=>'x', -pady=>10);
	$self->{'GUI'}{'NPCFrame3'}	= $self->{'GUI'}{'Frame'}->Frame(-height=>250, -width=>150)->pack(-fill=>'x', -pady=>10);

	# NPC Info Frames
	$self->{'GUI'}{'FrameNPC0'} = $self->{'GUI'}{'NPCFrame1'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC1'} = $self->{'GUI'}{'NPCFrame1'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC2'} = $self->{'GUI'}{'NPCFrame1'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC3'} = $self->{'GUI'}{'NPCFrame1'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC4'} = $self->{'GUI'}{'NPCFrame2'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC5'} = $self->{'GUI'}{'NPCFrame2'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC6'} = $self->{'GUI'}{'NPCFrame2'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC7'} = $self->{'GUI'}{'NPCFrame2'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	$self->{'GUI'}{'FrameNPC8'} = $self->{'GUI'}{'NPCFrame3'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
	
	foreach (0 .. 8)
	{
		$self->CreateNPCPanel($_);
	}
	
	if($self->{'Game'} == 2)
	{
		$self->{'GUI'}{'FrameNPC9'} = $self->{'GUI'}{'NPCFrame3'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
		$self->{'GUI'}{'FrameNPC10'} = $self->{'GUI'}{'NPCFrame3'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);
		$self->{'GUI'}{'FrameNPC11'} = $self->{'GUI'}{'NPCFrame3'}->Frame(-height=>250, -width=>150, -highlightcolor=>'black', -highlightbackground=>'black')->pack(-side=>'left', -padx=>25);

		$self->CreateNPCPanel(9);
		$self->CreateNPCPanel(10);
		$self->CreateNPCPanel(11);
	}
}

sub UpdateNPCPanels
{
	my $self = shift;
	
	foreach my $npc (0 .. 8)
	{
		next if (Exists($self->{'GUI'}{'FrameNPC' . $npc}) == 0);
		
		foreach($self->{'GUI'}{'FrameNPC' . $npc}->children)
		{
			$_->destroy;
		}
		
		if(KSE::Functions::NPC::GetNPCExists($npc) == 0)
		{
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-text=>"NPC\ndoesn't\nexist!", -font=>[-size=>15], -width=>6)->pack(-fill=>'both', -padx=>5, -pady=>5);
		}
		else
		{
			KSE::Functions::NPC::UpdateNPC($npc);
			$self->{'Data'}{'NPC' . $npc . 'Name'}		= KSE::Functions::NPC::GetName($npc);
			$self->{'Data'}{'NPC' . $npc . 'Class1'}	= KSE::Functions::NPC::GetClass($npc, 1);
			$self->{'Data'}{'NPC' . $npc . 'Class2'}	= KSE::Functions::NPC::GetClass($npc, 2);
			$self->{'Data'}{'NPC' . $npc . 'HP'}		= "HP: " . KSE::Functions::NPC::GetHP($npc);
			$self->{'Data'}{'NPC' . $npc . 'FP'}		= "FP: " . KSE::Functions::NPC::GetFP($npc);
			
			$self->{'GUI'}{'DataNPC' . $npc} = Imager->new(file=>KSE::Functions::NPC::GetPortrait($npc), type=>'tga');
			$self->{'GUI'}{'DataNPC' . $npc} = $self->{'GUI'}{'DataNPC' . $npc}->scale(scalefactor=>0.5);
			$self->{'GUI'}{'DataNPC' . $npc}->write(data=>\$self->{'Data'}{'ImageNPC' . $npc}, type=>'png');
			$self->{'GUI'}{'NPCImage' . $npc} = $self->{'GUI'}{'FrameNPC' . $npc}->Photo(-data=>encode_base64($self->{'Data'}{'ImageNPC' . $npc}), -format=>'png');
			
			$self->{'GUI'}{'FrameNPC' . $npc}->Button(-image=>$self->{'GUI'}{'NPCImage' . $npc}, -command=>sub { if(KSE::Functions::NPC::GetNPCExists($npc) == 1) { $self->{'NPCCode'}->($npc); } })->pack(-padx=>5, -pady=>5);
			
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Name'},	-width=>13)->pack(-fill=>'x', -padx=>5);
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class1'},	-width=>13)->pack(-fill=>'x', -padx=>5);
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class2'},	-width=>13)->pack(-fill=>'x', -padx=>5);
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'HP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
			$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'FP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
		}
	}
	
	if($self->{'Game'} == 2)
	{
		foreach my $npc (9 .. 11)
		{
			foreach($self->{'GUI'}{'FrameNPC' . $npc}->children)
			{
				$_->destroy;
			}
			
			if(KSE::Functions::NPC::GetNPCExists($npc) == 0)
			{
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-text=>"NPC\ndoesn't\nexist!", -font=>[-size=>15], -width=>6)->pack(-fill=>'both', -padx=>5, -pady=>5);
			}
			else
			{
				KSE::Functions::NPC::UpdateNPC($npc);
				$self->{'Data'}{'NPC' . $npc . 'Name'}		= KSE::Functions::NPC::GetName($npc);
				$self->{'Data'}{'NPC' . $npc . 'Class1'}	= KSE::Functions::NPC::GetClass($npc, 1);
				$self->{'Data'}{'NPC' . $npc . 'Class2'}	= KSE::Functions::NPC::GetClass($npc, 2);
				$self->{'Data'}{'NPC' . $npc . 'HP'}		= "HP: " . KSE::Functions::NPC::GetHP($npc);
				$self->{'Data'}{'NPC' . $npc . 'FP'}		= "FP: " . KSE::Functions::NPC::GetFP($npc);
				
				$self->{'GUI'}{'DataNPC' . $npc} = Imager->new(file=>KSE::Functions::NPC::GetPortrait($npc), type=>'tga');
				$self->{'GUI'}{'DataNPC' . $npc} = $self->{'GUI'}{'DataNPC' . $npc}->scale(scalefactor=>0.5);
				$self->{'GUI'}{'DataNPC' . $npc}->write(data=>\$self->{'Data'}{'ImageNPC' . $npc}, type=>'png');
				$self->{'GUI'}{'NPCImage' . $npc} = $self->{'GUI'}{'FrameNPC9'}->Photo(-data=>encode_base64($self->{'Data'}{'ImageNPC' . $npc}), -format=>'png');
				$self->{'GUI'}{'FrameNPC' . $npc}->Button(-image=>$self->{'GUI'}{'NPCImage' . $npc}, -command=>sub { if(KSE::Functions::NPC::GetNPCExists($npc) == 1) { $self->{'NPCCode'}->($npc); } })->pack(-padx=>5, -pady=>5);
				
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Name'},	-width=>13)->pack(-fill=>'x', -padx=>5);
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class1'},	-width=>13)->pack(-fill=>'x', -padx=>5);
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class2'},	-width=>13)->pack(-fill=>'x', -padx=>5);
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'HP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
				$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'FP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
			}
		}
	}
}

sub CreateNPCPanel
{
	my ($self, $npc) = @_;


	$self->{'GUI'}{'FrameNPC' . $npc}->bind('<ButtonPress-1>'=>[sub
	{
		my ($bogus, $self, $npc) = @_;
		foreach my $test (0 .. 8)
		{
			if($test != $npc)
			{
#				$self->{'GUI'}{'FrameNPC' . $test}->configure(-highlightbackground=>'black', -highlightcolor=>'black');
				$self->{'GUI'}{'FrameNPC' . $test}->configure(-relief=>'flat');
			}
			else
			{
#				$self->{'GUI'}{'FrameNPC' . $test}->configure(-highlightbackground=>'white', -highlightcolor=>'white');
				$self->{'GUI'}{'FrameNPC' . $test}->configure(-relief=>'raised');
			}
		}
		
		if($self->{'Game'} == 2)
		{
			foreach my $test (9 .. 11)
			{
				if($test != $npc)
				{
					$self->{'GUI'}{'FrameNPC' . $test}->configure(-relief=>'flat');
				}
				else
				{
					$self->{'GUI'}{'FrameNPC' . $test}->configure(-relief=>'raised');
				}
			}
		}
	}, $self, $npc]);
	
#	$self->{'GUI'}{'FrameNPC' . $npc}->bind('<Double-ButtonPress-1>'=>sub { if(KSE::Functions::NPC::GetNPCExists($npc) == 1) { $self->{'NPCCode'}->($npc); } } );

	if(KSE::Functions::NPC::GetNPCExists($npc) == 0)
	{
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-text=>"NPC\ndoesn't\nexist!", -font=>[-size=>15], -width=>6)->pack(-fill=>'both', -padx=>5, -pady=>5);
	}
	else
	{
		$self->{'Data'}{'NPC' . $npc . 'Name'}		= KSE::Functions::NPC::GetName($npc);
		$self->{'Data'}{'NPC' . $npc . 'Class1'}	= KSE::Functions::NPC::GetClass($npc, 1);
		$self->{'Data'}{'NPC' . $npc . 'Class2'}	= KSE::Functions::NPC::GetClass($npc, 2);
		$self->{'Data'}{'NPC' . $npc . 'HP'}		= "HP: " . KSE::Functions::NPC::GetHP($npc);
		$self->{'Data'}{'NPC' . $npc . 'FP'}		= "FP: " . KSE::Functions::NPC::GetFP($npc);
		
		$self->{'GUI'}{'DataNPC' . $npc} = Imager->new(file=>KSE::Functions::NPC::GetPortrait($npc), type=>'tga');
		if($self->{'Game'} == 2) { $self->{'GUI'}{'DataNPC' . $npc} = $self->{'GUI'}{'DataNPC' . $npc}->scale(scalefactor=>0.5); }
		
		my $data;
		$self->{'GUI'}{'DataNPC' . $npc}->write(data=>\$data, type=>'png');
		$self->{'Data'}{'ImageNPC' . $npc} = $data;
		
		$self->{'GUI'}{'NPCImage' . $npc} = $self->{'GUI'}{'FrameNPC' . $npc}->Photo(-data=>encode_base64($self->{'Data'}{'ImageNPC' . $npc}), -format=>'png');
		$self->{'GUI'}{'FrameNPC' . $npc}->Button(-image=>$self->{'GUI'}{'NPCImage' . $npc}, -command=>sub { if(KSE::Functions::NPC::GetNPCExists($npc) == 1) { $self->{'NPCCode'}->($npc); } })->pack(-padx=>5, -pady=>5);
		
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Name'},	-width=>13)->pack(-fill=>'x', -padx=>5);
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class1'},	-width=>13)->pack(-fill=>'x', -padx=>5);
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'Class2'},	-width=>13)->pack(-fill=>'x', -padx=>5);
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'HP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
		$self->{'GUI'}{'FrameNPC' . $npc}->Label(-textvariable=>\$self->{'Data'}{'NPC' . $npc . 'FP'},		-width=>13)->pack(-fill=>'x', -padx=>5);
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