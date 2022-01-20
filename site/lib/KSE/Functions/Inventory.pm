#line 1 "KSE/Functions/Inventory.pm"
package KSE::Functions::Inventory;

use Bioware::TwoDA;
use Bioware::TLK;
use Bioware::GFF;
use Bioware::BIF;

use Cwd;

use KSE::Data;

my $baseitem_2da	= Bioware::TwoDA->new();
my %Inventory;

sub SetItemIndex
{
	my ($template, $index) = @_;
	if(defined($Inventory{$template}{'Indexes'}) == 0)
	{
		$Inventory{$template}{'Indexes'} = ();
	}
	
	my $data = $Inventory{$template}{'Indexes'};
	push (@$data, $index);
	$Inventory{$template}{'Indexes'} = $data;
}

sub GetItemIndex
{
	my $template = shift;
	
	my $data = $Inventory{$template}{'Indexes'};
	return @$data;
}

sub SetItemCount
{
	my ($template, $count) = @_;
	
	$Inventory{$template}{'Count'} = $count;
}

sub GetItemCount
{
	my $template = shift;
	
	if(defined($Inventory{$template}{'Count'}) == 0)
	{
		$Inventory{$template}{'Count'} = 0;
	}
	
	return $Inventory{$template}{'Count'};
}

sub SetItemDesc
{
	my ($template, $desc) = @_;
		
	$Inventory{$template}{'Description'} = $desc;
}

sub GetItemDesc
{
	my $template = shift;
	
	if(defined($Inventory{$template}) == 0)
	{
		$Inventory{$template}{'Description'} = '<BLANK>';
	}
	
	return $Inventory{$template}{'Description'};
}

sub SetItemBase
{
	my ($template, $base) = @_;
	
	$Inventory{$template}{'Base'} = $base;
}

sub GetItemBase
{
	my $template = shift;
	
	return $Inventory{$template}{'Base'};
}

sub SetItemIcon
{
	my ($template, $icon) = @_;
	
	$Inventory{$template}{'Icon'} = $icon;
}

sub GetItemIcon
{
	my $template = shift;
	
	return $Inventory{$template}{'Icon'};
}

sub SetItemName
{
	my ($template, $name) = @_;
	
	$Inventory{$template}{'Name'} = $name;
}

sub GetItemName
{
	my $template = shift;
	
	return $Inventory{$template}{'Name'};
}

sub SetItemPath
{
	my ($template, $path) = @_;
	
	$Inventory{$template}{'Path'} = $path;
}

sub GetItemPath
{
	my $template = shift;
	
	return $Inventory{$template}{'Path'};
}

sub PopulateInventory
{
	my $self = shift;

	my $base_path		= KSE::Functions::Directory::GetGamePath();
	my $gff				= Bioware::GFF->new();
	print "7a\n";
	my $path_to_2da = KSE::Functions::Directory::GetFile('baseitems.2da');
	print "path: " . $path_to_2da . "\n";
	$baseitem_2da->read2da($path_to_2da);
	print "7b\n";
	
	%Inventory = ();
	
	my $j = 0;
	for (my $i = 0; $i < $baseitem_2da->{rows}; $i++)
	{

#		print "Adding Base Item Category $i " . Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $baseitem_2da->get_cell($i, 'name')) . ".\n";
		$self->AddItemCategory($i, Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $baseitem_2da->get_cell($i, 'name')));
		$j++;
	}
		
	$self->AddItemCategory($j, 'Extras');
	print "7c\n";
	
	my $BIF_obj		= Bioware::BIF->new($base_path);
	my @bif_files	= split(/ /, $BIF_obj->get_files('uti'));
	print "7d\n";
	# Check the Override, and all the subfolders.
	opendir OVERDIR, "$base_path/override" or die("Can't! $!\n");
	my $basecwd = getcwd;
	my @folders = grep { !(/\/\.+$/) && -d } map {"$base_path/override/$_"} readdir(OVERDIR);
	closedir OVERDIR;

	chdir "$base_path/override";
	my @over_files = glob "*.uti";
	
#	print "Folder: $base_path/override\n";
#	print "Number of override files: " . scalar(@over_files) . "\n";
#	exit;
	# Check the Override's subfolders
	my %over_folders;
###	if($self->{'Game'} == 2)
	if(KSE::Data::GetData('None', 'Game') == 2)
	{
		foreach my $folder (@folders)
		{
#			print "Folder: $folder\n";
			opendir OVERSUBDIR, $folder;
			chdir "$base_path/override/$folder";
			$over_folders{$folder} = glob "*.uti";
			closedir OVERSUBDIR;
		}
	}
	chdir $basecwd;
	
	# Start from the last BIFF archives, then work through the Override and sub-folders,
	# adding the path to the file (and filename) to %files_to_check (overwriting earlier versions as we go).
	my %files_to_check;
	foreach my $file (@bif_files)
	{
		$files_to_check{$file} = 'BIF';
	}

	foreach my $file (@over_files)
	{
#		print "Inventory file: $file\n";
		$files_to_check{$file} = $base_path . '/Override';
	}
	
###	if($self->{'Game'} == 2)
	if(KSE::Data::GetData('None', 'Game') == 2)
	{
		foreach my $folder (@folders)
		{
			foreach my $file ($over_folders{$folder})
			{
				$files_to_check{$file} = $folder;
			}
		}
	}
	print "7e\n";
	
	my $i = 0;
	my $ii = keys %files_to_check;
	foreach my $uti (sort {$a cmp $b} keys %files_to_check)
	{
		$ii--;
		next if $uti eq undef or $uti eq '';
		$i++;
		$ii++;
		
		if($files_to_check{$uti} eq 'BIF')
		{
			$BIF_obj->extract_resource('data\\templates.bif', $uti, KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			$gff->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
		}
		else
		{
			$gff->read_gff_file($files_to_check{$uti} . "/$uti");
		}
		
		my ($baseitem, $equipslot, $raceslot, $name, $icon, $image, $tag, $template, $count, $path) = (0, '', '', '', 0, '');
		
		$template	= $gff->{Main}{Fields}[$gff->{Main}->fbl('TemplateResRef')]{Value};
		$baseitem	= $gff->{Main}{Fields}[$gff->{Main}->fbl('BaseItem')]{Value};
		$equipslot	= $baseitem_2da->get_cell($baseitem, 'equipableslots');
		$equipslot2	= $baseitem_2da->get_cell($baseitem, 'equipableslots');
		$raceslot	= $baseitem_2da->get_cell($baseitem, 'droidorhuman');
		
		if($equipslot eq '0x00001')		{ $equipslot = 'Head';		$equipslot2 = 'Head';		}
		elsif($equipslot eq '0x00002')	{ $equipslot = 'Armor';		$equipslot2 = 'Armor';		}
		elsif($equipslot eq '0x00008')	{ $equipslot = 'Gloves';	$equipslot2 = 'Gloves';		}
		elsif($equipslot eq '0x00010')	{ $equipslot = 'Weapon';	$equipslot2 = 'Weapon';		}
		elsif($equipslot eq '0x00030')	{ $equipslot = 'Weapon';	$equipslot2 = 'Weapon';		}
		elsif($equipslot eq '0x00180')	{ $equipslot = 'Arm';		$equipslot2 = 'Arm';		}
		elsif($equipslot eq '0x00200')	{ $equipslot = 'Implant';	$equipslot2 = 'Implant';	}
		elsif($equipslot eq '0x00208')	{ $equipslot = 'Implant';	$equipslot2 = 'Gloves';		}
		elsif($equipslot eq '0x00400')	{ $equipslot = 'Belt';		$equipslot2 = 'Belt';		}
		else							{ $equipslot = 'None';		$equipslot2 = 'None';		}
		
		my $modelvar = $gff->{Main}->fbl('ModelVariation');
		if(defined($modelvar))
		{
			$modelvar = $gff->{Main}{Fields}[$modelvar]{Value};
		}
		else
		{
			$modelvar = $gff->{Main}{Fields}[$gff->{Main}->fbl('TextureVar')]{Value};
		}
		
		if($modelvar < 10) { $modelvar = '00' . $modelvar; }
		elsif($modelvar < 100) { $modelvar = '0' . $modelvar; }
		
		$icon = 'i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_$modelvar";
		#$image = KSE::Functions::Directory::GetFileImage('i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_$modelvar");
		if($files_to_check{$uti} ne 'BIF')
		{
#			print "UTI: $uti\tIcon: $icon\n";
		}
		
		$name		= $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'StringRef'};
#		print "File: $uti Source: $files_to_check{$uti} $template\n";
		if($name == -1)
		{
			$name = $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
		}
		else
		{
			$name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $name);
		}
		
		$desc = $gff->{Main}{Fields}[$gff->{Main}->fbl('DescIdentified')]{Value}{'StringRef'};
		$tag = $gff->{Main}{Fields}[$gff->{Main}->fbl('Tag')]{Value};
		$path = $files_to_check{$uti};
		if($desc == -1)
		{
			$desc = $gff->{Main}{Fields}[$gff->{Main}->fbl('DescIdentified')]{Value}{'Substrings'}[0]{'Value'};
		}
		else
		{
			$desc = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $desc);
		}
		
		KSE::Data::SetItemData($template, $template, 'Resref');
		KSE::Data::SetItemData($template, $template, 'Template');
		KSE::Data::SetItemData($template, $baseitem, 'BaseItem');
		KSE::Data::SetItemData($template, $raceslot, 'Race');
		KSE::Data::SetItemData($template, $equipslot, 'EquipSlot1');
		KSE::Data::SetItemData($template, $equipslot2, 'EquipSlot2');
		KSE::Data::SetItemData($template, $tag, 'Tag');
		KSE::Data::SetItemData($template, $name, 'Name');
		KSE::Data::SetItemData($template, $icon, 'Icon');
#		KSE::Data::SetItemData($template, $image, 'Image');
		KSE::Data::SetItemData($template, $desc, 'Description');
		KSE::Data::SetItemData($template, $count, 'Count');
		KSE::Data::SetItemData($template, $path, 'Path');
		
		SetItemBase($template, $baseitem);
		SetItemName($template, $name);
		SetItemIcon($template, $icon);
		SetItemDesc($template, $desc);
		SetItemCount($template, $count);
		SetItemPath($template, $files_to_check{$uti});
	}

#	PopulateCountFromSave();
	print "7f\n";
	my $i = 0;
	my $ii = keys %Inventory;
	foreach my $template (sort {$a cmp $b} keys %Inventory)
	{
		$i++;
		KSE::GUI::Main::SetResourceStep("Processing item $i of $ii.");
#		print "template: $template\n";
		my $baseitem	= GetItemBase($template);
		
		if($baseitem > $j) { $baseitem = $j; }
		my $name		= GetItemName($template);
		my $count		= GetItemCount($template);
		my $path		= GetItemPath($template);
		
		if($path eq 'INV')
		{
#			print "template: $template\tName: $name\tBaseitem: $baseitem\n";
		}
		
		if($baseitem eq '' or defined($baseitem) == 0)
		{
			print "Template is failing $template\n";
			next;
		}
		
		$self->AddItemToList($baseitem, $name, $template, $count, $path);
		
		KSE::GUI::Main::SetResourceProgress(50 + ($i / $ii)*50);
	}
}

sub PopulateCountFromSave
{
	print "here\n";
#	my $gff = KSE::Functions::Saves::GetInventoryRes();
	my $gff = Bioware::GFF->new();
	$gff->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/sav/INVENTORY.res');
	
	my $itemlist = $gff->{Main}{Fields}{Value};

	my $i = -1;
	foreach my $item_struct (@$itemlist)
	{
		$i++;
		
		my $template = lc ($item_struct->{Fields}[$item_struct->fbl('Tag')]{Value});
		my $baseitem = $item_struct->{Fields}[$item_struct->fbl('BaseItem')]{Value};
		my $modelvar = $item_struct->fbl('ModelVariation');
		if(defined($modelvar))
		{
			$modelvar = $item_struct->{Fields}[$modelvar]{Value};
		}
		else
		{
			$modelvar = $item_struct->{Fields}[$gff->{Main}->fbl('TextureVar')]{Value};
		}
		
		if($modelvar < 10) { $modelvar = '00' . $modelvar; }
		elsif($modelvar < 100) { $modelvar = '0' . $modelvar; }
		
		my $icon = 'i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_$modelvar";
#		print "Template of $i is $template and Base is $baseitem\n";
		
		SetItemBase($template, $baseitem);
		SetItemIcon($template, $icon);
		SetItemIndex($template, $i);
		SetItemPath($template, 'INV');
		
		$name = $item_struct->{Fields}[$item_struct->fbl('LocalizedName')]{Value}{'StringRef'};
		
		if($name == -1)
		{
			$name = $item_struct->{Fields}[$item_struct->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
		}
		else
		{
			$name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $name);
		}

		my $desc = $item_struct->{Fields}[$item_struct->fbl('DescIdentified')]{Value}{'StringRef'};
		
		if($desc == -1)
		{
			$desc = $item_struct->{Fields}[$item_struct->fbl('DescIdentified')]{Value}{'Substrings'}[0]{'Value'};
		}
		else
		{
			$desc = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $desc);
		}
		
		SetItemCount($template, (GetItemCount($template) + 1));
#		print "Item count for $template is " . GetItemCount($template) . "\n";
		SetItemName($template, $name);
		SetItemDesc($template, $desc);
	}
}

sub SaveInventoryToSave
{
#	my $gff			= KSE::Functions::Saves::GetInventoryRes();
	my $gff			= Bioware::GFF->new();
	$gff->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/sav/INVENTORY.res');
	
	my $gff_file	= Bioware::GFF->new();
	my $BIF_obj		= Bioware::BIF->new(KSE::Functions::Directory::GetGamePath());
	my $itemlist	= undef; # I will add structs to this as events go on.
	my @inv_files	= ();
	
	foreach my $file (sort {$a cmp $b} keys %Inventory)
	{
		next if GetItemCount($file) <= 0;
		
		print "Item: $file\n\tCount: " . GetItemCount($file) . "\n";
		my $type = GetItemPath($file);
		my $main = undef;
		
		if($type eq 'BIF')
		{
			print "\tUsing file from templates.bif.\n";
			$BIF_obj->extract_resource("data\\templates.bif", $file . '.uti', KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			$gff_file->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
		}
		elsif($type eq 'INV')
		{
			print "\tUsing file data from INVENTORY.res.\n";
			push(@inv_files, $file);
			next;
		}
		else
		{
			print "\tUsing file from path: $type\n";
			$gff_file->read_gff_file($type);
		}
		
		my $item_struct = Bioware::GFF::Struct->new('ID'=>0);
		
		my @field_types = (FIELD_DWORD, FIELD_INT, FIELD_BYTE, FIELD_DWORD, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_LIST, FIELD_WORD, FIELD_BYTE, FIELD_CEXOSTRING, FIELD_DWORD);

		my $field_index = -1;
		foreach my $field ('AddCost', 'BaseItem', 'Charges', 'Cost', 'Identified', 'MaxCharges', 'ModelVariation', 'NonEquippable', 'Plot', 'PropertiesList', 'StackSize', 'Stolen', 'Tag', 'Upgrades')
		{
			$field_index++;
			my $value = $gff_file->{Main}{Fields}[$gff_file->{Main}->fbl($field)]{Value};
#			print "Value of $field: $value\n";
			$item_struct->createField('Type'=>$field_types[$field_index], 'Label'=>$field, 'Value'=>$value);
		}
		
		foreach('DescIdentified', 'LocalizedName')
		{
			$item_struct->createField('Type'=>FIELD_CEXOLOCSTRING, 'Label'=>$_, 'StringRef'=>$gff_file->{Main}{Fields}[$gff_file->{Main}->fbl($_)]{Value}{'StringRef'}, 'Value'=>@{$gff_file->{Main}{Fields}[$gff_file->{Main}->fbl($_)]{Value}{'Substrings'}});
		}
		
		$field_index = 0;
		foreach('DELETING', 'Dropable', 'NewItem', 'Pickpocketable')
		{
			$field_index++;
			my $value = 0;
			
			if($field_index > 1) { $value = 1; }
			$item_struct->createField('Type'=>FIELD_BYTE, 'Label'=>$_, 'Value'=>$value);
		}
		
		push(@$itemlist, $item_struct);
#		$gff->write_gff_file(KSE::Functions::Main::GetBaseDir() . '/INVENTORY.res');
	}
	
	foreach my $file (@inv_files)
	{
		next if $file eq '' or defined($file) == 0;
		my @indices	= GetItemIndex($file);
#		print "Indices: @indices.\t" . join(", ", @indices) . "\n";
		
		foreach my $index (@indices)
		{
#			print "Index of $file is $index\n";
			my $inv_struct = $gff->{Main}{Fields}{Value}[$index];
#			print "Inv_struct = $inv_struct\n";
			my $item_struct = Bioware::GFF::Struct->new('ID'=>0);

			my @field_types = (FIELD_DWORD, FIELD_INT, FIELD_BYTE, FIELD_DWORD, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_LIST, FIELD_WORD, FIELD_BYTE, FIELD_CEXOSTRING, FIELD_DWORD, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE, FIELD_BYTE);
			
			my $field_index = -1;
			foreach my $field ('AddCost', 'BaseItem', 'Charges', 'Cost', 'Identified', 'MaxCharges', 'ModelVariation', 'NonEquippable', 'Plot', 'PropertiesList', 'StackSize', 'Stolen', 'Tag', 'Upgrades', 'DELETING', 'Dropable', 'NewItem', 'Pickpocketable')
			{
				$field_index++;
#				print "Processing Field $field\n";
				$item_struct->createField('Type'=>$field_types[$field_index], 'Label'=>$field, 'Value'=>$inv_struct->{Fields}[$inv_struct->fbl($field)]{Value});
			}
			
			foreach my $field ('DescIdentified', 'LocalizedName')
			{
#				if($inv_struct->{Fields}[$inv_struct->fbl($field)]{'Value'}{'StringRef'} == -1)
#				{
					$item_struct->createField(
						'Type'=>FIELD_CEXOLOCSTRING,
						'Label'=>$field,
						'StringRef'=>$inv_struct->{Fields}[$inv_struct->fbl($field)]{'Value'}{'StringRef'},
						'Value'=>@{$gff->{Main}{Fields}{Value}[$index]{Fields}[$gff->{Main}{Fields}{Value}[$index]->fbl($field)]{'Value'}{'Substrings'}});
#				}
#				else
#				{
#					$item_struct->createField(
#						'Type'=>FIELD_CEXOLOCSTRING,
#						'Label'=>$field,
#						'StringRef'=>$inv_struct->{Fields}[$inv_struct->fbl($field)]{'Value'}{'StringRef'});
#				}
			}
			
			push(@$itemlist, $item_struct);
		}
	}
	
	# Now to assign the new inventory
	$gff->{Main}{Fields}{Value} = $itemlist;
	$gff->write_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/sav/INVENTORY.res');
#	$gff->write_gff_file(KSE::Functions::Main::GetBaseDir() . '/INVENTORY.res');
#	exit;
}

return 1;