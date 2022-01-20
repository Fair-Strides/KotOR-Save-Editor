#line 1 "KSE/GUI/Target.pm"
package KSE::GUI::Target;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use MIME::Base64;

use KSE::Data;

use Tk;
use Tk::Balloon;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;

my $CurrentTarget = 'Player';

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $type = shift;
	my $game = shift;
	my $coderef = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Type'}		= $type;
	$self->{'Data'}		= {};
	$self->{'GUI'}		= {};
	$self->{'Targets'}	= ();
    bless $self,$class;
    return $self;
}

sub GetTarget
{
	return $CurrentTarget;
}

sub Create
{
	my ($self, $parent) = @_;
	
	$self->{'GUI'}{'Parent'}	= $parent;
	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Parent'}->Frame(-height=>64, -width=>1000)->pack(-side=>'bottom', -anchor=>'s', -pady=>25, -expand=>1);
#	$self->{'GUI'}{'Frame'}		= $self->{'GUI'}{'Frame1'}->Frame(-height=>64, -width=>1000)->pack(-side=>'left', -anchor=>'w', -pady=>25, -expand=>1);
	$self->{'GUI'}{'Balloon'}	= $self->{'GUI'}{'Parent'}->Balloon(-postcommand=>sub {$self->UpdateTargetInfo(); return 1; });
	
	$self->{'GUI'}{'Label'}	= $self->{'GUI'}{'Frame'}->Label(-text=>"There are no player characters or party members to modify.", -font=>[-size=>14])->pack(-fill=>'both', -expand=>1, -anchor=>'center');
	
	$self->{'GUI'}{'IconImager'} = Imager->new();
#	$self->{'GUI'}{'Frame'}->repeat(1000, sub { $self->UpdateTargetInfo(); });
}

sub UpdateTargetInfo
{
	my $self = shift;
	if(scalar $self->{'Targets'} > 0)
	{
		foreach(keys %{$self->{'Data'}{'Tooltips'}})
		{
			$self->{'Data'}{'Tooltips'}{$_} = join("\n", KSE::Data::GetData($_, 'FirstName'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData($_, 'Class1', 'Class')) . ' ' . KSE::Data::GetData($_, 'Class1', 'Level'), KSE::Functions::Classes::GetClassName(KSE::Data::GetData($_, 'Class2', 'Class')) . ' ' . KSE::Data::GetData($_, 'Class2', 'Level'), KSE::Data::GetData($_, 'HitPoints') . '/' . KSE::Data::GetData($_, 'MaxHitPoints') . ' HP', KSE::Data::GetData($_, 'ForcePoints') . '/' . KSE::Data::GetData($_, 'MaxForcePoints') . ' FP');
			
			$self->{'GUI'}{'Balloon'}->detach($self->{'GUI'}{'Target'}{$_});
			$self->{'GUI'}{'Balloon'}->attach($self->{'GUI'}{'Target'}{$_}, -balloonmsg=>$self->{'Data'}{'Tooltips'}{$_});
		}
	}
}

sub RemoveAllTargets
{
	my $self = shift;
	if(scalar $self->{'Targets'} > 0)
	{
		foreach(keys %{$self->{'Data'}{'Tooltips'}})
		{
			$self->{'GUI'}{'Target'}{$_}->destroy;
			$self->{'GUI'}{'Balloon'}->detach($self->{'GUI'}{'Target'}{$_});
		}
	}
	$self->{'GUI'}{'Label'}->pack(-fill=>'both', -expand=>1, -anchor=>'center');
}

sub AddTarget
{
	my ($self, $identifier, $portrait, $name, $class1, $class2, $hp, $fp) = @_;
	
	$self->{'GUI'}{'IconImager'}->read(file=>$portrait, type=>'tga');
	$self->{'GUI'}{'IconImager'} = $self->{'GUI'}{'IconImager'}->scale(xpixels=>96, ypixels=>96);
	$self->{'GUI'}{'IconImager'}->write(data=>\$self->{'Data'}{'IconImageData'}, type=>'png');
	$self->{'GUI'}{'Image_' . $identifier} = $self->{'GUI'}{'Parent'}->Photo(-data=>encode_base64($self->{'Data'}{'IconImageData'}), -format=>'png', -height=>96, -width=>96);
	
	$self->{'GUI'}{'Target'}{$identifier} = $self->{'GUI'}{'Frame'}->Button(-image=>$self->{'GUI'}{'Image_' . $identifier}, -relief=>'flat', -command=>sub{ $CurrentTarget = $identifier; $self->RaiseTarget($identifier); }, -width=>96, -height=>96);
		
	$self->{'Data'}{'Tooltips'}{$identifier} = join("\n", $name, $class1, $class2, $hp, $fp);
	$self->{'GUI'}{'Balloon'}->attach($self->{'GUI'}{'Target'}{$identifier}, -balloonmsg=>$self->{'Data'}{'Tooltips'}{$identifier});
	
	foreach my $widget ($self->{'GUI'}{'Frame'}->packSlaves)
	{
		if($widget == $self->{'GUI'}{'Label'})
		{
			$widget->packForget;
			last;
		}
	}
	
	push(@{$self->{'Targets'}}, $self->{'GUI'}{'Target'}{$identifier});
}

sub RaiseTarget
{
	my ($self, $target) = @_;
	
	foreach my $key (keys %{$self->{'GUI'}{'Target'}})
	{
#		print "\$key is $key and target is $target: ";
		if($key ne $target)
		{
#			print "didn't match.\n";
			$self->{'GUI'}{'Target'}{$key}->configure(-relief=>'flat');
		}
		else
		{
#			print "matched.\n";
			$self->{'GUI'}{'Target'}{$key}->configure(-relief=>'raised');
			KSE::GUI::Classes::ChangeTarget(GetTarget());
			KSE::GUI::Equipment::ChangeTarget(GetTarget());
			KSE::GUI::Feats::ChangeTarget(GetTarget());
			KSE::GUI::Main::ChangeTargetStats(GetTarget());
			KSE::GUI::Powers::ChangeTarget(GetTarget());
		}
	}
}

sub ShowAllTargets
{
	my $self = shift;
	foreach(reverse @{$self->{'Targets'}})
	{
		$_->pack(-side=>'left', -anchor=>'w', -fill=>'y', -in=>$self->{'GUI'}{'Frame'});
	}
	$self->RaiseTarget('Player');
}

sub destroy
{
	my $self = shift;
	
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