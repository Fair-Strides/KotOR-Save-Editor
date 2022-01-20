#line 1 "KSE/GUI/Equipment.pm"
package KSE::GUI::Equipment;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use MIME::Base64 qw(encode_base64);

use KSE::Data;

use KSE::Functions::Equipment;

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
	
#	$self->{'GUI'}{'TargetSelection'} = KSE::GUI::GameControls->new($game);	
#	$self->{'GUI'}{'TargetSelection'}->CreatePCorNPCDropdown($parent, 'Equipment');
	
	KSE::GUI::Main::SetResourceStep('Creating Equipment basic layout frame.');
	# Slots Frame
	$self->{'GUI'}{'Frame1'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -fill=>'y', -anchor=>'nw');
	
	# Equipment Frame
	$self->{'GUI'}{'Frame2'}	= $self->{'GUI'}{'Parent'}->Frame(-height=>25, -width=>150)->pack(-side=>'left', -anchor=>'nw');
	
	# Slots GUI
	$self->{'GUI'}{'SlotsFrame'}	= $self->{'GUI'}{'Frame1'}->Scrolled('Frame', -scrollbars=>'oe', -height=>350, -width=>400)->pack(-fill=>'both', -expand=>1);
#	$self->{'GUI'}{'InfoFrame'}		= $self->{'GUI'}{'Frame1'}->Frame(-height=>250, -width=>150)->pack(-fill=>'x');
	
	$self->{'GUI'}{'ListPicImager'} = Imager->new();
	KSE::GUI::Main::SetResourceProgress(21);
	
	my $i = 0;
	KSE::GUI::Main::SetResourceStep('Generating equipment slots with current data.');
	foreach my $slot ('Head', 'Implant', 'RArm', 'LArm', 'Gloves', 'Armor', 'Belt', 'RWeapon', 'LWeapon')
	{
		$i++;
		my ($image, $name, $icon) = KSE::Functions::Equipment::GetItemInSlot(KSE::GUI::Target::GetTarget(), $slot);
#		print "Image for $slot is $image\n";
		
		$self->{'GUI'}{'ListPicImager'}->read(file=>$image, type=>'tga');
		
#		print "Game: $self->{'Game'}\nType: KSE::GUI::Target::GetTarget()\nSlot: $slot\nIcon: $icon\nDefault Icon: " . KSE::Functions::Equipment::GetSlotDefaultIcon(KSE::GUI::Target::GetTarget(), $slot) . "\n";
		if($self->{'Game'} == 2 && $icon eq KSE::Functions::Equipment::GetSlotDefaultIcon(KSE::GUI::Target::GetTarget(), $slot))
		{
#			print "Here1 $icon\n";
			$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
		}
		$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
		$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
		
		$self->{'Data'}{'Slots_' . $slot}				= $name;
		$self->{'Data'}{'Slots_' . $slot . '_Image'}	= $icon;
		
		$self->{'GUI'}{'Slot_Image_' . $slot} = $self->{'GUI'}{'SlotsFrame'}->Photo(-data=>encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png', -height=>64, -width=>64);
		
		$self->{'GUI'}{'Slots_' . $slot} = $self->{'GUI'}{'SlotsFrame'}->Button(-command=>[\&SelectSlot, $self, $slot], -textvariable=>\$self->{'Data'}{'Slots_' . $slot}, -image=>$self->{'GUI'}{'Slot_Image_' . $slot}, -anchor=>'w', -relief=>'flat', -compound=>'left', -width=>400, -height=>64)->pack(-fill=>'x');
		
		KSE::GUI::Main::SetResourceProgress(21 + ($i * 9));
	}
	KSE::GUI::Main::SetResourceProgress(70);
	
	# INFO LABELS
	# $self->{'GUI'}{'InfoLabel1'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel1'}->Label(-text=>'Head Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel1'}->Label(-textvariable=>\$self->{'Data'}{'Slots_Head'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel2'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel2'}->Label(-text=>'Implant Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel2'}->Label(-textvariable=>\$self->{'Data'}{'Slots_Implant'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel3'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel3'}->Label(-text=>'Right Arm Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel3'}->Label(-textvariable=>\$self->{'Data'}{'Slots_RArm'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel4'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel4'}->Label(-text=>'Left Arm Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel4'}->Label(-textvariable=>\$self->{'Data'}{'Slots_LArm'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel5'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel5'}->Label(-text=>'Gloves Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel5'}->Label(-textvariable=>\$self->{'Data'}{'Slots_Gloves'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel6'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel6'}->Label(-text=>'Armor Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel6'}->Label(-textvariable=>\$self->{'Data'}{'Slots_Armor'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel7'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel7'}->Label(-text=>'Belt Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel7'}->Label(-textvariable=>\$self->{'Data'}{'Slots_Belt'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel8'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel8'}->Label(-text=>'Right Weapon Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel8'}->Label(-textvariable=>\$self->{'Data'}{'Slots_RWeapon'})->pack(-side=>'left', -padx=>10);
	
	# $self->{'GUI'}{'InfoLabel9'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
	# $self->{'GUI'}{'InfoLabel9'}->Label(-text=>'Left Weapon Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
	# $self->{'GUI'}{'InfoLabel9'}->Label(-textvariable=>\$self->{'Data'}{'Slots_LWeapon'})->pack(-side=>'left', -padx=>10);
	
	if($self->{'Game'} == 2)
	{
		KSE::GUI::Main::SetResourceStep('Generating equipment slots for TSL with current data.');
		foreach my $slot ('RWeapon2', 'LWeapon2')
		{
			my ($image, $name, $icon) = KSE::Functions::Equipment::GetItemInSlot(KSE::GUI::Target::GetTarget(), $slot);
			
			$self->{'GUI'}{'ListPicImager'}->read(file=>$image, type=>'tga');
			
			if($self->{'Game'} == 2 && $icon eq KSE::Functions::Equipment::GetSlotDefaultIcon(KSE::GUI::Target::GetTarget(), $slot))
			{
				$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
			}
			$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
			
			$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
			
			$self->{'Data'}{'Slots_' . $slot}				= $name;
			$self->{'Data'}{'Slots_' . $slot . '_Image'}	= $icon;
			
			$self->{'GUI'}{'Slot_Image_' . $slot} = $self->{'GUI'}{'SlotsFrame'}->Photo(-data=>encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png', -height=>64, -width=>64);
			
			$self->{'GUI'}{'Slots_' . $slot} = $self->{'GUI'}{'SlotsFrame'}->Button(-command=>[\&SelectSlot, $self, $slot], -textvariable=>\$self->{'Data'}{'Slots_' . $slot}, -image=>$self->{'GUI'}{'Slot_Image_' . $slot}, -anchor=>'w', -relief=>'flat', -compound=>'left', -width=>150, -height=>64)->pack(-fill=>'x');
		}
		
		# $self->{'GUI'}{'InfoLabel10'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
		# $self->{'GUI'}{'InfoLabel10'}->Label(-text=>'Right Weapon 2 Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
		# $self->{'GUI'}{'InfoLabel10'}->Label(-textvariable=>\$self->{'Data'}{'Slots_RWeapon2'})->pack(-side=>'left', -padx=>10);
	
		# $self->{'GUI'}{'InfoLabel11'} = $self->{'GUI'}{'InfoFrame'}->Frame(-height=>25, -width=>150)->pack(-fill=>'x', -pady=>0);
		# $self->{'GUI'}{'InfoLabel11'}->Label(-text=>'Left Weapon 2 Slot: ', -anchor=>'w', -width=>25)->pack(-side=>'left', -padx=>10);
		# $self->{'GUI'}{'InfoLabel11'}->Label(-textvariable=>\$self->{'Data'}{'Slots_LWeapon2'})->pack(-side=>'left', -padx=>10);
	}
	KSE::GUI::Main::SetResourceProgress(80);
	
	# Equipment GUI
	$self->{'GUI'}{'List'}	= $self->{'GUI'}{'Frame2'}->Scrolled('HList', -scrollbars=>'osoe', -columns=>4, -drawbranch=>0, -header=>1, -height=>40, -indicator=>1, -itemtype=>'text', -selectborderwidth=>0, -separator=>'#', -width=>76, -browsecmd=>[\&SelectSlotItem, $self], -command=>[\&ConfirmSlotItem, $self])->pack(-fill=>'x', -padx=>10, -pady=>5);
	
	$self->{'GUI'}{'List'}->columnWidth(0, '-char', 16);
	$self->{'GUI'}{'List'}->columnWidth(1, '-char', 28);
	$self->{'GUI'}{'List'}->columnWidth(2, '-char', 15);
	$self->{'GUI'}{'List'}->columnWidth(3, '-char', 15);

#	my $header_button0 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'    ', -command=>[\&SortSlotInventory, $self, 0]);
	my $header_button1 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'Name', -command=>[\&SortSlotInventory, $self, 1]);
	my $header_button2 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'Template ResRef', -command=>[\&SortSlotInventory, $self, 2]);
	my $header_button3 = $self->{'GUI'}{'List'}->Button(-anchor=>'center', -text=>'Tag', -command=>[\&SortSlotInventory, $self, 3]);
	
#	$self->{'GUI'}{'List'}->headerCreate(0, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button0);
	$self->{'GUI'}{'List'}->headerCreate(1, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button1);
	$self->{'GUI'}{'List'}->headerCreate(2, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button2);
	$self->{'GUI'}{'List'}->headerCreate(3, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button3);
	
	KSE::GUI::Main::SetResourceProgress(90);
}

sub ChangeEquipmentExternal
{
	my ($self, $target) = @_;
	
	$self->{'Type'} = $target;
	
	foreach my $slot ('Head', 'Implant', 'RArm', 'LArm', 'Gloves', 'Armor', 'Belt', 'RWeapon', 'LWeapon', 'RWeapon2', 'LWeapon2')
	{
		next if defined($self->{'GUI'}{'Slots_' . $slot}) == 0;
		
		my ($image, $name, $icon) = KSE::Functions::Equipment::GetItemInSlot(KSE::GUI::Target::GetTarget(), $slot);
		
		$self->{'GUI'}{'ListPicImager'}->read(file=>$image, type=>'tga');

		if($self->{'Game'} == 2 && $icon eq KSE::Functions::Equipment::GetSlotDefaultIcon(KSE::GUI::Target::GetTarget(), $slot))
		{
#			print "Here2 $icon\n";
			$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
		}
		$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
		$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
		
		$self->{'GUI'}{'Slot_Image_' . $slot}->put(encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png');
		$self->{'GUI'}{'Slots_' . $slot}->configure(-image=>$self->{'GUI'}{'Slot_Image_' . $slot});
		$self->{'Data'}{'Slots_' . $slot}				= $name;
		$self->{'Data'}{'Slots_' . $slot . '_Image'}	= $icon;
	}
}

sub ChangeTarget
{
	my $target = shift;
	my $self = KSE::GUI::Main::GetPanelSelf('Equipment');
	
	$self->ChangeEquipmentExternal($target);
}

sub SelectSlot
{
	my ($self, $slot) = @_;
	
	$self->{'Data'}{'Slot'} = $slot;
	$self->{'GUI'}{'Slots_' . $slot}->configure(-relief=>'sunken');
	
	foreach my $slot2 ('Head', 'Implant', 'RArm', 'LArm', 'Gloves', 'Armor', 'Belt', 'RWeapon', 'LWeapon', 'RWeapon2', 'LWeapon2')
	{
		if($slot2 eq $slot) { next; }
		next if defined($self->{'GUI'}{'Slots_' . $slot2}) == 0;
		
		$self->{'GUI'}{'Slots_' . $slot2}->configure(-relief=>'flat');
	}
	
	$self->ClearSlotItems();
	
	KSE::Functions::Equipment::PopulateEquipment($self, $slot);
	$self->{'GUI'}{'List'}->update;
}

sub ClearSlotItems
{
	my $self = shift;
	
	my @children = $self->{'GUI'}{'List'}->info('children');
#	print "# of entries: " . scalar @children . "\n";
	
	foreach my $entry (@children)
	{
#		print "Deleting $entry\n";
		$self->{'GUI'}{'List'}->delete('entry', $entry);
	}
	
	$self->{'GUI'}{'List'}->update;
}

sub AddSlotItem
{
	my ($self, $uti, $icon, $name, $template, $tag, $path) = @_;

	$self->{'GUI'}{'ListPicImager'}->read(file=>KSE::Functions::Directory::GetFileImage($icon), type=>'tga') or die("Can't! " . $self->{'GUI'}{'ListPicImager'}->errstr() . "\n");

	$self->{'GUI'}{'ListPicImager'} = $self->{'GUI'}{'ListPicImager'}->scale(xpixels=>64, ypixels=>64);
	
	$self->{'GUI'}{'ListPicImager'}->write(data=>\$self->{'Data'}{'FakeImage'}, type=>'png');
	$self->{'GUI'}{'ListPic' . $path . $uti} = $self->{'GUI'}{'List'}->Photo(-data=>encode_base64($self->{'Data'}{'FakeImage'}), -format=>'png');

	$self->{'GUI'}{'List'}->add($path . $uti, -data=>{Path=>$path, Icon=>$icon});
	$self->{'GUI'}{'List'}->itemCreate($path . $uti, 0, -itemtype=>'imagetext', -image=>$self->{'GUI'}{'ListPic' . $path . $uti}, -showimage=>1, -showtext=>0);
	$self->{'GUI'}{'List'}->itemCreate($path . $uti, 1, -text=>$name);
	$self->{'GUI'}{'List'}->itemCreate($path . $uti, 2, -text=>$template);
	$self->{'GUI'}{'List'}->itemCreate($path . $uti, 3, -text=>$tag);
}

sub SelectSlotItem
{
	my ($self, $item) = @_;
	
	$self->{'Data'}{'Item'}	= $item;

#	$self->{'GUI'}{'List'}->itemConfigure($item, 0, -background=>'blue');
#	$self->{'GUI'}{'List'}->itemConfigure($item, 1, -background=>'blue');
#	$self->{'GUI'}{'List'}->itemConfigure($item, 2, -background=>'blue');
#	$self->{'GUI'}{'List'}->itemConfigure($item, 3, -background=>'blue');
}

sub ConfirmSlotItem
{
	my $self = shift;
	
	$self->{'GUI'}{'Slots_' . $self->{'Data'}{'Slot'}}->configure(-image=>$self->{'GUI'}{'ListPic' . $self->{'Data'}{'Item'}});
	
	$self->{'Data'}{'Slots_' . $self->{'Data'}{'Slot'}} = $self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 1, '-text');
	
	print "Item: " . $self->{'Data'}{'Item'} . "\n";
	
	foreach my $key (keys %{$self->{'GUI'}{'List'}->info('data', $self->{'Data'}{'Item'})})
	{
		print "Key: $key\tValue: " . ${$self->{'GUI'}{'List'}->info('data', $self->{'Data'}{'Item'})}{$key} . "\n";
	}
	
	KSE::Functions::Equipment::SetSlotItem(
	KSE::GUI::Target::GetTarget(),
	$self->{'Data'}{'Slot'},
	${$self->{'GUI'}{'List'}->info('data', $self->{'Data'}{'Item'})}{Icon},
	$self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 1, '-text'),
	$self->{'GUI'}{'List'}->itemCget($self->{'Data'}{'Item'}, 2, '-text'),
	${$self->{'GUI'}{'List'}->info('data', $self->{'Data'}{'Item'})}{Path});
}

sub SortSlotInventory
{
	my $self	= shift;
	my $col		= shift;

	my @entries = $self->{'GUI'}{'List'}->info('children');
	my @to_be_sorted =();

	foreach my $entry(@entries)
	{
		push @to_be_sorted,
		[
			$self->{'GUI'}{'List'}->itemCget($entry,0,'image'),
			$self->{'GUI'}{'List'}->itemCget($entry,1,'text'),
			$self->{'GUI'}{'List'}->itemCget($entry,2,'text'),
			$self->{'GUI'}{'List'}->itemCget($entry,3,'text'),
		];
	}

	my @sorted = sort {	$a->[$col] cmp $b->[$col] || # primary sort ascii
						$a->[1] <=> $b->[1]          # secondary sort numeric
					  } @to_be_sorted;

	my $entry = 0;
	foreach my $aref (@sorted)
	{
#		print $aref->[0],' ',$aref->[1],' ',$aref->[1],"\n";
		$self->{'GUI'}{'List'}->itemConfigure($entry, 0, 'image' => $aref->[0]);  
		$self->{'GUI'}{'List'}->itemConfigure($entry, 1, 'text' => $aref->[1]); 
		$self->{'GUI'}{'List'}->itemConfigure($entry, 2, 'text' => $aref->[2]); 
		$self->{'GUI'}{'List'}->itemConfigure($entry, 3, 'text' => $aref->[2]); 
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