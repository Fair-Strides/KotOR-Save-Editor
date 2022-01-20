#line 1 "KSE/GUI/Inventory.pm"
package KSE::GUI::Inventory;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Functions::Directory;

use MIME::Base64 qw(encode_base64);

use Tk;
use Tk::BrowseEntry;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::NumEntryPlain;
use Tk::RadioButton;
use TK::ROText;
use Tk::Tree;

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	my $game = shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
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
	print "1\n";
	KSE::GUI::Main::SetResourceStep('Creating Inventory basic layout frame.');
	# Inventory List
	$self->{'GUI'}{'Frame1'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	$self->{'GUI'}{'Frame2'} = $self->{'GUI'}{'Parent'}->Frame(-height=>60, -width=>150)->pack(-side=>'right', -fill=>'both');
	KSE::GUI::Main::SetResourceProgress(10);
	
	KSE::GUI::Main::SetResourceStep('Creating Inventory table.');
	print "2\n";
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame1'}->Scrolled('Tree', -scrollbars=>'osoe', -columns=>3, -drawbranch=>0, -header=>1, -height=>45, -indicator=>1, -itemtype=>'text', -selectborderwidth=>0, -separator=>'#', -width=>64, -browsecmd=>[\&selectItem, $self])->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	$self->{'GUI'}{'List'}->columnWidth(0, '-char', 35);
	$self->{'GUI'}{'List'}->columnWidth(1, '-char', 19);
	$self->{'GUI'}{'List'}->columnWidth(2, '-char', 10);

#	my $header_button0 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'Name', -command=>[\&sortInventory, $self, 0]);
#	my $header_button1 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'Template ResRef', -command=>[\&sortInventory, $self, 1]);
#	my $header_button2 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'# Owned', -command=>[\&sortInventory, $self, 2]);
	
#	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button0);
#	$self->{'GUI'}{'List'}->headerCreate(1, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button1);
#	$self->{'GUI'}{'List'}->headerCreate(2, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button2);
	
	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'text', -borderwidth=>-2, -text=>'Name');
	$self->{'GUI'}{'List'}->headerCreate(1, -itemtype=>'text', -borderwidth=>-2, -text=>'Template ResRef');
	$self->{'GUI'}{'List'}->headerCreate(2, -itemtype=>'text', -borderwidth=>-2, -text=>'# Owned');

	KSE::GUI::Main::SetResourceProgress(25);
	print "3\n";
	KSE::GUI::Main::SetResourceStep('Creating supply buttons, preview image, and description.');
	# Adding and Subtracting items
	$self->{'GUI'}{'Frame3'} = $self->{'GUI'}{'Frame2'}->Frame(-height=>60, -width=>150)->pack(-expand=>1, -fill=>'x');
	$self->{'GUI'}{'Frame3_left'} = $self->{'GUI'}{'Frame3'}->Frame(-height=>60, -width=>150)->pack(-expand=>1, -side=>'left');
	$self->{'GUI'}{'Frame3_right'} = $self->{'GUI'}{'Frame3'}->Frame(-height=>60, -width=>150)->pack(-expand=>1, -side=>'right');

	$self->{'GUI'}{'ASLabelsMinus'} = $self->{'GUI'}{'Frame3_left'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -padx=>10, -pady=>10);
	$self->{'GUI'}{'ASLabelsEntry'} = $self->{'GUI'}{'Frame3_left'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -padx=>10, -pady=>10);
	$self->{'GUI'}{'ASLabelsPlus'} = $self->{'GUI'}{'Frame3_left'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -padx=>10, -pady=>10);
	
	$self->{'GUI'}{'ASLabelsMinus'}->Button(-text=>'-10', -font=>[-size=>12], -command=>[\&subtractItem, $self, 10])->pack(-side=>'left', -padx=>2);
	$self->{'GUI'}{'ASLabelsMinus'}->Button(-text=>'-5', -font=>[-size=>12],  -command=>[\&subtractItem, $self, 5])->pack(-side=>'left', -padx=>2);
	$self->{'GUI'}{'ASLabelsMinus'}->Button(-text=>'-1', -font=>[-size=>12],  -command=>[\&subtractItem, $self, 1])->pack(-side=>'left', -padx=>2);
	$self->{'GUI'}{'ASLabelsEntry'}->NumEntryPlain(-minvalue=>0, -width=>15, -bell=>0, -textvariable=>\$self->{'Data'}{'Count'}, -font=>[-size=>12])->pack(-side=>'left', -padx=>5);
	$self->{'GUI'}{'ASLabelsPlus'}->Button(-text=>'+1', -font=>[-size=>12],  -command=>[\&addItem, $self, 1])->pack(-side=>'left', -padx=>2);
	$self->{'GUI'}{'ASLabelsPlus'}->Button(-text=>'+5', -font=>[-size=>12],  -command=>[\&addItem, $self, 5])->pack(-side=>'left', -padx=>2);
	$self->{'GUI'}{'ASLabelsPlus'}->Button(-text=>'+10', -font=>[-size=>12], -command=>[\&addItem, $self, 10])->pack(-side=>'left', -padx=>2);
	
	$self->{'GUI'}{'IconImager'} = Imager->new();
	$self->{'GUI'}{'IconImager'}->read(file=>KSE::Functions::Directory::GetFileImage('****'), type=>'tga');
#	$self->{'GUI'}{'IconImager'} = $self->{'GUI'}{'IconImager'}->scale(scalefactor=>2.0);
	$self->{'GUI'}{'IconImager'} = $self->{'GUI'}{'IconImager'}->scale(xpixels=>128, ypixels=>128);
	$self->{'GUI'}{'IconImager'}->write(data=>\$self->{'Data'}{'IconImageData'}, type=>'png');
	$self->{'GUI'}{'IconPhoto'}  = $self->{'GUI'}{'Frame3_right'}->Photo(-data=>encode_base64($self->{'Data'}{'IconImageData'}), -format=>'png', -height=>128, -width=>128);
	$self->{'GUI'}{'IconLabel'}  = $self->{'GUI'}{'Frame3_right'}->Label(-image=>$self{'GUI'}{'IconPhoto'})->pack(-fill=>'both');
	print "4\n";
	# Item Description
	$self->{'GUI'}{'Frame4'} = $self->{'GUI'}{'Frame2'}->Frame(-height=>60, -width=>150)->pack(-fill=>'both', -pady=>20, -anchor=>'nw');
	$self->{'GUI'}{'IText'} = $self->{'GUI'}{'Frame4'}->ROText(-wrap=>'word', -background=>'SystemButtonFace', -font=>[-size=>12], -height=>30, -width=>120, -relief=>'flat', -state=>'disabled')->pack(-fill=>'both', -padx=>5, -pady=>5);
	$self->{'GUI'}{'IText'}->insert('end', ' ');
	$self->{'GUI'}{'IText'}->tagAdd('centered', "1.0");
	$self->{'GUI'}{'IText'}->tagConfigure('centered', -justify=>'center');
	KSE::GUI::Main::SetResourceProgress(50);
	print "5\n";
	KSE::GUI::Main::SetResourceStep('Looking for items to register.');
	$self->FillList();
}

sub FillList
{
	my $self = shift;
	
	$self->ClearList();
	print "6\n";
	KSE::Functions::Inventory::PopulateInventory($self);
	print "7\n";
}

sub ClearList
{
	my $self = shift;
	
	$self->{'GUI'}{'List'}->delete('all');
}

sub RefreshList
{
	my $self = shift;
	
	my @categories = $self->{'GUI'}{'List'}->info('children');
	my $c = 1;
	foreach my $cat (@categories)
	{
		print "Category $cat\n" if $c == 1;
		my @entries = $self->{'GUI'}{'List'}->info('children', $cat);
		
		foreach my $entry (@entries)
		{
			print "Entry: $cat#$entry\n" if $c == 1;
			my $name = $self->{'GUI'}{'List'}->itemCget($entry, 1, -text);
			$self->{'GUI'}{'List'}->itemConfigure($entry, 2, -text=>KSE::Functions::Inventory::GetItemCount($name));
		}
		$c++;
	}
}
sub AddItemCategory
{
	my ($self, $path, $name) = @_;
	
	$self->{'GUI'}{'List'}->add($path, -text=>$name);
}

sub AddItemToList
{
	my ($self, $baseitem, $name, $template, $count, $path) = @_;
	
#	print "self $self\nbaseitem $baseitem\nname $name\ntemplate $template\ncount $count\npath $path\n\n";
	$self->{'GUI'}{'List'}->add($baseitem . '#' . $template, -data=>$path);
	$self->{'GUI'}{'List'}->itemCreate($baseitem . '#' . $template, 0, -text=>$name);
	$self->{'GUI'}{'List'}->itemCreate($baseitem . '#' . $template, 1, -text=>$template);
	$self->{'GUI'}{'List'}->itemCreate($baseitem . '#' . $template, 2, -text=>$count);
	
	$self->{'GUI'}{'List'}->open($baseitem);
	$self->{'GUI'}{'List'}->autosetmode;
	$self->{'GUI'}{'List'}->close($baseitem);
}

sub selectItem
{
	my ($self, $item) = @_;
	
	return if !($item =~ /\#/);
	
	$item =~ /(.*)\#(.*)/;
	my  $template = $2;
	
	if(defined($self->{'Data'}{'Item'}) == 1)
	{
		KSE::Functions::Inventory::SetItemCount($self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 1, 'text'), $self->{'Data'}{'Count'});
	}
	
	my $temp = $self->{'GUI'}{'List'}->itemCget($item, 1, 'text');
	
	$self->{'Data'}{'Item'}		= $item;
	$self->{'Data'}{'Icon'}		= KSE::Functions::Inventory::GetItemIcon($temp);
	$self->{'Data'}{'Count'}	= KSE::Functions::Inventory::GetItemCount($temp);
	$self->{'Data'}{'Desc'}		= KSE::Functions::Inventory::GetItemDesc($temp);
	$self->{'Data'}{'Name'}		= KSE::Functions::Inventory::GetItemName($temp);
	
#	print "Trying to find " . $self->{'Data'}{'Icon'} . "\n";
	
	$self->{'GUI'}{'IconImager'}->read(file=>KSE::Functions::Directory::GetFileImage($self->{'Data'}{'Icon'}), type=>'tga');
	#$self->{'GUI'}{'IconImager'} = $self->{'GUI'}{'IconImager'}->scale(scalefactor=>2.0);
	$self->{'GUI'}{'IconImager'} = $self->{'GUI'}{'IconImager'}->scale(xpixels=>128, ypixels=>128);
	$self->{'GUI'}{'IconImager'}->write(data=>\$self->{'Data'}{'IconImageData'}, type=>'png');
	$self->{'GUI'}{'IconPhoto'}->put(encode_base64($self->{'Data'}{'IconImageData'}), -format=>'png');
	$self->{'GUI'}{'IconLabel'}->configure(-image=>$self->{'GUI'}{'IconPhoto'});
	
	$self->{'GUI'}{'IText'}->configure(-state=>'normal');
	$self->{'GUI'}{'IText'}->delete("1.0", 'end');
	$self->{'GUI'}{'IText'}->insert("1.0", $self->{'Data'}{'Name'}, 'centered', "\n\n" . $self->{'Data'}{'Desc'});
	$self->{'GUI'}{'IText'}->configure(-state=>'disabled');
}

sub subtractItem
{
	my ($self, $amount) = @_;
	
	return if (defined($self->{'Data'}{'Item'}) == 0);
	
	$self->{'Data'}{'Count'} -= $amount;
	$self->{'GUI'}{'List'}->itemConfigure($self->{'Data'}{'Item'}, 2, 'text', $self->{'Data'}{'Count'});
	KSE::Functions::Inventory::SetItemCount($self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 1, 'text'), $self->{'Data'}{'Count'});
}

sub addItem
{
	my ($self, $amount) = @_;
#	print "Self: $self, amount: $amount\n";
	
	return if (defined($self->{'Data'}{'Item'}) == 0);
	
	$self->{'Data'}{'Count'} += $amount;
	$self->{'GUI'}{'List'}->itemConfigure($self->{'Data'}{'Item'}, 2, 'text', $self->{'Data'}{'Count'});
	KSE::Functions::Inventory::SetItemCount($self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 1, 'text'), $self->{'Data'}{'Count'});
}

sub sortInventory
{
	my $self	= shift;
	my $col		= shift;

	my @entries = $self->{'GUI'}{'List'}->info('children');
	my @to_be_sorted =();

	foreach my $entry(@entries)
	{
		push @to_be_sorted,
		[
			$self->{'GUI'}{'List'}->itemCget($entry,0,'text'),
			$self->{'GUI'}{'List'}->itemCget($entry,1,'text'),
			$self->{'GUI'}{'List'}->itemCget($entry,2,'text'),
		];
	}

	my @sorted = sort {	$a->[$col] cmp $b->[$col] || # primary sort ascii
						$a->[1] <=> $b->[1]          # secondary sort numeric
					  } @to_be_sorted;

	my $entry = 0;
	foreach my $aref (@sorted)
	{
#		print $aref->[0],' ',$aref->[1],' ',$aref->[1],"\n";
		$self->{'GUI'}{'List'}->itemConfigure($entry, 0, 'text' => $aref->[0]);  
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, 'text' => $aref->[1]); 
		$self->{'GUI'}{'List'}->itemConfigure($entry, 2, 'text' => $aref->[2]); 
		$entry++;
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