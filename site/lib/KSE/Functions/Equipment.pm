#line 1 "KSE/Functions/Equipment.pm"
package KSE::Functions::Equipment;

use Bioware::GFF;
use Bioware::TLK;
use Bioware::TwoDA;

use Cwd;

use KSE::Data;

use KSE::Functions::Directory;
use KSE::Functions::Saves;

my %Slot_Items;

sub GetEquipmentSlots
{
	my $target = shift;
	my @slots = ();
	
	foreach my $slot ('Head', 'Armor', 'Gloves', 'RWeapon', 'LWeapon', 'LArm', 'RArm', 'Implant', 'Belt', 'RWeapon2', 'LWeapon2')
	{
###		my $item = KSE::Functions::Saves::GetSaveData($target, 'Equipment', $slot, 'Resref');
		my $item = KSE::Data::GetData($target, 'Equipment', $slot, 'Resref');
		
		if(defined($item) == 1)
		{
#			print "Using $slot\n";
			push(@slots, $slot);
		}
	}
	
	return @slots;
}

sub GetSlotID
{
	my $slot = shift;

	if($slot eq 'Head')			{ return 1;			}
	elsif($slot eq 'Armor')		{ return 2;			}
	elsif($slot eq 'Gloves')	{ return 8;			}
	elsif($slot eq 'RWeapon')	{ return 16;		}
	elsif($slot eq 'LWeapon')	{ return 32;		}
	elsif($slot eq 'LArm')		{ return 128;		}
	elsif($slot eq 'RArm')		{ return 256;		}
	elsif($slot eq 'Implant')	{ return 512;		}
	elsif($slot eq 'Belt')		{ return 1024;		}
	elsif($slot eq 'RWeapon2')	{ return 262144;	}
	elsif($slot eq 'LWeapon2')	{ return 524288;	}
}

sub GetSlotName
{
	my $slot = shift;

	if($slot == 1)			{ return 'Head';		}
	elsif($slot == 2)		{ return 'Armor';		}
	elsif($slot == 8)		{ return 'Gloves';		}
	elsif($slot == 16)		{ return 'RWeapon';		}
	elsif($slot == 32)		{ return 'LWeapon';		}
	elsif($slot == 128)		{ return 'LArm';		}
	elsif($slot == 256)		{ return 'RArm';		}
	elsif($slot == 512)		{ return 'Implant';		}
	elsif($slot == 1024)	{ return 'Belt';		}
	elsif($slot == 262144)	{ return 'RWeapon2';	}
	elsif($slot == 524288)	{ return 'LWeapon2';	}

}

sub GetSlotDefaultIcon
{
	my ($target, $slot) = @_;
	
	my $game = KSE::Functions::Saves::GetGame(KSE::Functions::Saves::GetCurrentSave());
	
###	my $race = KSE::Functions::Saves::GetSaveData($target, 'Race');
	my $race = KSE::Data::GetData($target, 'Race');
	my $icon = undef;
	
	if($race == 6)	{ $icon = 'i'; }
	else			{ $icon = 'id'; }
	
	if($game == 1)
	{
		if($slot eq 'Head')			{ $icon .= 'head';		}
		elsif($slot eq 'Armor')		{ $icon .= 'armor';		}
		elsif($slot eq 'Gloves')	{ $icon .= 'hands';		}
		elsif($slot eq 'RWeapon')	{ $icon .= 'weap_r';	}
		elsif($slot eq 'LWeapon')	{ $icon .= 'weap_l';	}
		elsif($slot eq 'LArm')		{ $icon .= 'forearm_L';	}
		elsif($slot eq 'RArm')		{ $icon .= 'forearm_r';	}
		elsif($slot eq 'Implant')	{ $icon .= 'implant';	}
		elsif($slot eq 'Belt')		{ $icon .= 'belt';		}
	}
	else
	{
		if($slot eq 'Head')			{ $icon .= 'head';		}
		elsif($slot eq 'Armor')		{ $icon .= 'armor';		}
		elsif($slot eq 'Gloves')	{ $icon .= 'hands';		}
		elsif($slot eq 'RWeapon')	{ $icon .= 'weap_r';	}
		elsif($slot eq 'LWeapon')	{ $icon .= 'weap_l';	}
		elsif($slot eq 'LArm')		{ $icon .= 'forearm_l';	}
		elsif($slot eq 'RArm')		{ $icon .= 'forearm_r';	}
		elsif($slot eq 'Implant')	{ $icon .= 'implant';	}
		elsif($slot eq 'Belt')		{ $icon .= 'belt';		}
		elsif($slot eq 'RWeapon2')	{ $icon .= 'weap_r';	}
		elsif($slot eq 'LWeapon2')	{ $icon .= 'weap_l';	}
	}
	
	return $icon;
}

sub GetItemInSlot
{
	my ($target, $slot) = @_;
	
#	print "Icon for $slot is " . KSE::Functions::Saves::GetSaveData($target, 'Equipment', $slot, 'Icon') . "\n";
###	my $icon	= KSE::Functions::Saves::GetSaveData($target, 'Equipment', $slot, 'Icon');
	my $icon	= KSE::Data::GetData($target, 'Equipment', $slot, 'Icon');
	my $image	= KSE::Functions::Directory::GetFileImage($icon);
###	my $name	= KSE::Functions::Saves::GetSaveData($target, 'Equipment', $slot, 'Name');
	my $name	= KSE::Data::GetData($target, 'Equipment', $slot, 'Name');
	
	if(defined($name) == 0) { $name = '      <None>';	$image = KSE::Functions::Directory::GetFileImage(GetSlotDefaultIcon($target, $slot)); $icon = GetSlotDefaultIcon($target, $slot); }
	else					{ $name = '      ' . $name; }
	
	return ($image, $name, $icon);
}

sub SetSlotItem
{
	my ($target, $slot, $icon, $name, $resref, $path) = @_;
	print "Target: $target\nSlot: $slot\nIcon: $icon\nName: $name\nResref: $resref\nPath: $path\n\n";
###	KSE::Functions::Saves::SetSaveData($icon,	$target, 'Equipment', $slot, 'Icon');
###	KSE::Functions::Saves::SetSaveData($name,	$target, 'Equipment', $slot, 'Name');
###	KSE::Functions::Saves::SetSaveData($resref, $target, 'Equipment', $slot, 'Resref');
###	KSE::Functions::Saves::SetSaveData($path,	$target, 'Equipment', $slot, 'Path');
###
	KSE::Data::SetData($target, $icon,	'Equipment', $slot, 'Icon');
	KSE::Data::SetData($target, $name,	'Equipment', $slot, 'Name');
	KSE::Data::SetData($target, $resref, 'Equipment', $slot, 'Resref');
	KSE::Data::SetData($target, $path,	'Equipment', $slot, 'Path');
}

sub GetSlotItemPath
{
	my ($target, $slot) = @_;
	
###	return KSE::Functions::Saves::GetSaveData($target, 'Equipment', $slot, 'Path');
	return KSE::Data::GetData($target, 'Equipment', $slot, 'Path');
}

sub ResetSlotItems
{
	foreach (keys %Slot_Items)
	{
		delete $Slot_Items{$_};
	}
}

sub PopulateEquipment
{
	my ($self, $slot) = @_;
	
	my $slot_text = $slot;
	if($slot =~ /Weapon/) { $slot_text = 'Weapon'; }
	elsif($slot =~ /Arm$/) { $slot_text = 'Arm'; }
	#
#	print "Slot: $slot\nSlot Text: $slot_text\n";
	#
	# if(defined($Slot_Items{$slot_text}) == 0)
	# {
# #		my $s = <STDIN>;
		#
		# my $base_path		= KSE::Functions::Directory::GetGamePath();
		# my $gff				= Bioware::GFF->new();
		# my $baseitem_2da	= Bioware::TwoDA->new();
		# $baseitem_2da->read2da(KSE::Functions::Directory::GetFile('baseitems.2da'));
		#
		# my $BIF_obj		= Bioware::BIF->new(KSE::Functions::Directory::GetGamePath());
		# my @bif_files	= split(/ /, $BIF_obj->get_files('uti'));
# #		print "Bif Files: " . scalar @bif_files . "\n";
		#
		# opendir OVERDIR, "$base_path/override" or die("Can't! $!\n");
		# my $basecwd = getcwd;
		# my @folders = grep { !(/\/\.+$/) && -d } map {"$base_path/override/$_"} readdir(OVERDIR);
		# closedir OVERDIR;
		#
		# chdir "$base_path/override";
		# my @over_files = glob "*.uti";
		#
# #		print "Override files: " . scalar @over_files . "\n";
		#
		# # Check the Override's subfolders
		# my %over_folders = undef;
		# if($self->{'Game'} == 2)
		# {
			# foreach my $folder (@folders)
			# {
				# opendir OVERSUBDIR, $folder;
				# chdir "$base_path/override/$folder";
				# $over_folders{$folder} = glob "*.uti";
				# closedir OVERSUBDIR;
			# }
		# }
		# chdir $basecwd;
		#
		# # Start from the last BIFF archives, then work through the Override and sub-folders,
		# # adding the path to the file (and filename) to %files_to_check (overwriting earlier versions as we go).
		# my %files_to_check = undef;
		# foreach my $file (@bif_files)
		# {
			# $files_to_check{$file} = 'BIF';
		# }
		#
		# foreach my $file (@over_files)
		# {
			# $files_to_check{$file} = $base_path . '/Override';
		# }
		#
		# if($self->{'Game'} == 2)
		# {
			# foreach my $folder (keys %over_folders)
			# {
				# foreach my $file ($over_folders{$folder})
				# {
					# $files_to_check{$file} = $folder;
				# }
			# }
		# }
		#
		# foreach my $uti (sort {$a cmp $b} keys %files_to_check)
		# {
			# next if $uti eq '' or $uti eq ' ';
			# if($files_to_check{$uti} eq 'BIF')
			# {
				# $BIF_obj->extract_resource("data\\templates.bif", $uti, KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
				# $gff->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			# }
			# else
			# {
				# $gff->read_gff_file($files_to_check{$uti} . "/$uti");
			# }
			#
			# # Find out which slots and race the item is for.
			# my $baseitem	= $gff->{Main}{Fields}[$gff->{Main}->fbl('BaseItem')]{Value};
			# my $equipslot	= $baseitem_2da->get_cell($baseitem, 'equipableslots');
			# my $raceslot	= $baseitem_2da->get_cell($baseitem, 'droidorhuman');
			#
			# # Find Target's race and compare.
# #			my $race = KSE::Functions::Saves::GetSaveData($self->{'Type'}, 'Race');
# #			
# #			next if ($raceslot == 1 && $race == 5); # Item is for Humans only.
# #			next if ($raceslot == 2 && $race == 6); # Item is for Droids only.
			#
			# my ($image, $icon, $name, $template, $tag, $path);
			#
			# my $modelvar = $gff->{Main}->fbl('ModelVariation');
			# if(defined($modelvar))
			# {
				# $modelvar = $gff->{Main}{Fields}[$gff->{Main}->fbl('ModelVariation')]{Value};
			# }
			# else
			# {
				# $modelvar = $gff->{Main}{Fields}[$gff->{Main}->fbl('TextureVar')]{Value};
			# }
			#
			# if($modelvar < 10) { $modelvar = '00' . $modelvar; }
			# elsif($modelvar < 100) { $modelvar = '0' . $modelvar; }
			#
			# $icon = 'i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_$modelvar";
			# $image	= KSE::Functions::Directory::GetFileImage($icon);
			#
			# $name	= $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'StringRef'};
			#
			# if($name == -1)
			# {
				# $name = $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			# }
			# else
			# {
				# $name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $name);
			# }
			#
			# $template	= $gff->{Main}{Fields}[$gff->{Main}->fbl('TemplateResRef')]{Value};
			# $tag		= $gff->{Main}{Fields}[$gff->{Main}->fbl('Tag')]{Value};		
			# $path		= $files_to_check{$uti};
			#
			# # If we got here, then we can add it to the list!
# #			if($equipslot eq '0x00001' && $slot eq 'Head')								{ push (@files_to_do, [$uti, $image, $name, $template, $tag, $path]); }
			# if($equipslot eq '0x00001')		{ $Slot_Items{'Head'}{$uti}		= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00002')	{ $Slot_Items{'Armor'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00008')	{ $Slot_Items{'Gloves'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00010')	{ $Slot_Items{'Weapon'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00030')	{ $Slot_Items{'Weapon'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00180')	{ $Slot_Items{'Arm'}{$uti}		= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00200')	{ $Slot_Items{'Implant'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00208')	{ $Slot_Items{'Implant'}{$uti}	= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; $Slot_Items{'Gloves'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00400')	{ $Slot_Items{'Belt'}{$uti}		= {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
		# }
	# }
	# else
	# {
		# my $base_path		= KSE::Functions::Directory::GetGamePath();
		# my $gff				= Bioware::GFF->new();
		# my $baseitem_2da	= Bioware::TwoDA->new();
		# $baseitem_2da->read2da(KSE::Functions::Directory::GetFile('baseitems.2da'));
		#
		# my $BIF_obj		= Bioware::BIF->new(KSE::Functions::Directory::GetGamePath());
		#
		# opendir OVERDIR, "$base_path/override" or die("Can't! $!\n");
		# my $basecwd = getcwd;
		# my @folders = grep { !(/\/\.+$/) && -d } map {"$base_path/override/$_"} readdir(OVERDIR);
		# closedir OVERDIR;
		#
		# chdir "$base_path/override";
		# my @over_files = glob "*.uti";
		#
# #		print "Override files: " . scalar @over_files . "\n";
		#
		# # Check the Override's subfolders
		# my %over_folders = undef;
		# if($self->{'Game'} == 2)
		# {
			# foreach my $folder (@folders)
			# {
				# opendir OVERSUBDIR, $folder;
				# chdir "$base_path/override/$folder";
				# $over_folders{$folder} = glob "*.uti";
				# closedir OVERSUBDIR;
			# }
		# }
		# chdir $basecwd;
		#
		# my %files_to_check = undef;
		# my $in = 1;
		# foreach my $file (@over_files)
		# {
			# if($in == 1) { $in = 2; print "First item found is $file.\n"; }
			# next if (defined($Slot_Items{'Head'}{$file}) == 1);
			# next if (defined($Slot_Items{'Armor'}{$file}) == 1);
			# next if (defined($Slot_Items{'Gloves'}{$file}) == 1);
			# next if (defined($Slot_Items{'Weapon'}{$file}) == 1);
			# next if (defined($Slot_Items{'Weapon'}{$file}) == 1);
			# next if (defined($Slot_Items{'Arm'}{$file}) == 1);
			# next if (defined($Slot_Items{'Implant'}{$file}) == 1);
			# next if (defined($Slot_Items{'Gloves'}{$file}) == 1);
			# next if (defined($Slot_Items{'Belt'}{$file}) == 1);
			#
			# $files_to_check{$file} = $base_path . '/Override';
		# }
		#
		# if($self->{'Game'} == 2)
		# {
			# foreach my $folder (keys %over_folders)
			# {
				# next if $folder eq "";
				# print "folder is $folder\n.";
				# foreach my $file ($over_folders{$folder})
				# {
					# if($in == 2) { $in = 3; print "First item found in $folder is $file.\n"; }
					# next if (defined($Slot_Items{'Head'}{$file}) == 1);
					# next if (defined($Slot_Items{'Armor'}{$file}) == 1);
					# next if (defined($Slot_Items{'Gloves'}{$file}) == 1);
					# next if (defined($Slot_Items{'Weapon'}{$file}) == 1);
					# next if (defined($Slot_Items{'Weapon'}{$file}) == 1);
					# next if (defined($Slot_Items{'Arm'}{$file}) == 1);
					# next if (defined($Slot_Items{'Implant'}{$file}) == 1);
					# next if (defined($Slot_Items{'Gloves'}{$file}) == 1);
					# next if (defined($Slot_Items{'Belt'}{$file}) == 1);
					#
					# $files_to_check{$file} = $folder;
				# }
			# }
		# }
		#
		# foreach my $uti (sort {$a cmp $b} keys %files_to_check)
		# {
			# next if $uti eq '' or $uti eq ' ';
			# if($files_to_check{$uti} eq 'BIF')
			# {
				# $BIF_obj->extract_resource("data\\templates.bif", $uti, KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
				# $gff->read_gff_file(KSE::Functions::Main::GetBaseDir() . '/temp/fake.uti');
			# }
			# else
			# {
				# $gff->read_gff_file($files_to_check{$uti} . "/$uti");
			# }
			#
			# # Find out which slots and race the item is for.
			# my $baseitem	= $gff->{Main}{Fields}[$gff->{Main}->fbl('BaseItem')]{Value};
			# my $equipslot	= $baseitem_2da->get_cell($baseitem, 'equipableslots');
			# my $raceslot	= $baseitem_2da->get_cell($baseitem, 'droidorhuman');
			#
# #			next if $equipslot eq '0x00001' && $slot eq 'Head'		&& (defined($Slot_Items{'Head'}{$uti}) == 1);
# #			next if $equipslot eq '0x00002' && $slot eq 'Armor'		&& (defined($Slot_Items{'Armor'}{$uti}) == 1);
# #			next if $equipslot eq '0x00008' && $slot eq 'Gloves'	&& (defined($Slot_Items{'Gloves'}{$uti}) == 1);
# #			next if $equipslot eq '0x00010' && ($slot =~ /Weapon/)	&& (defined($Slot_Items{'Weapon'}{$uti}) == 1);
# #			next if $equipslot eq '0x00030' && ($slot =~ /Weapon/)	&& (defined($Slot_Items{'Weapon'}{$uti}) == 1);
# #			next if $equipslot eq '0x00180' && ($slot =~ /Arm/)		&& (defined($Slot_Items{'Arm'}{$uti}) == 1);
# #			next if $equipslot eq '0x00200' && $slot eq 'Implant'	&& (defined($Slot_Items{'Implant'}{$uti}) == 1);
# #			next if $equipslot eq '0x00208' && ($slot eq 'Implant' || $slot eq 'Gloves') && (defined($Slot_Items{'Gloves'}{$uti}) == 1);
# #			next if $equipslot eq '0x00400' && $slot eq 'Belt'		&& (defined($Slot_Items{'Belt'}{$uti}) == 1);
			#
			# # Find Target's race and compare.
# #			my $race = KSE::Functions::Saves::GetSaveData($self->{'Type'}, 'Race');
# #			
# #			next if ($raceslot == 1 && $race == 5); # Item is for Humans only.
# #			next if ($raceslot == 2 && $race == 6); # Item is for Droids only.
			#
			# my ($image, $name, $template, $tag, $path);
			#
			# my $modelvar = $gff->{Main}->fbl('ModelVariation');
			# if(defined($modelvar))
			# {
				# $modelvar = $gff->{Main}{Fields}[$modelvar]{Value};
			# }
			# else
			# {
				# $modelvar = $gff->{Main}{Fields}[$gff->{Main}->fbl('TextureVar')]{Value};
			# }
			#
			# if($modelvar < 10) { $modelvar = '00' . $modelvar; }
			# elsif($modelvar < 100) { $modelvar = '0' . $modelvar; }
			#
			# $image	= KSE::Functions::Directory::GetFileImage('i' . $baseitem_2da->get_cell($baseitem, 'itemclass') . "_0$modelvar");
			#
			# $name	= $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'StringRef'};
			#
			# if($name == -1)
			# {
				# $name = $gff->{Main}{Fields}[$gff->{Main}->fbl('LocalizedName')]{Value}{'Substrings'}[0]{'Value'};
			# }
			# else
			# {
				# $name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $name);
			# }
			#
			# $template	= $gff->{Main}{Fields}[$gff->{Main}->fbl('TemplateResRef')]{Value};
			# $tag		= $gff->{Main}{Fields}[$gff->{Main}->fbl('Tag')]{Value};
			# $path		= $files_to_check{$uti};
			#
			# # If we got here, then we can add it to the list!
			# if($equipslot eq '0x00001')		{ $Slot_Items{'Head'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00002')	{ $Slot_Items{'Armor'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00008')	{ $Slot_Items{'Gloves'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00010')	{ $Slot_Items{'Weapon'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00030')	{ $Slot_Items{'Weapon'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00180')	{ $Slot_Items{'Arm'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00200')	{ $Slot_Items{'Implant'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00208')	{ $Slot_Items{'Implant'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; $Slot_Items{'Gloves'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
			# elsif($equipslot eq '0x00400')	{ $Slot_Items{'Belt'}{$uti} = {Race=>$raceslot, Image=>$image, Icon=>$icon, Name=>$name, Template=>$template, Tag=>$tag, Path=>$path}; }
		# }
	# }
	
	my ($image, $icon, $name, $template, $tag, $path);

	# Okay! All the sorting and what-not is done. Now I can just worry about adding the items in @files_to_do
	# to the Equipment List. Well, I'll need their special info first.
#	foreach my $uti (@files_to_do)
###	foreach my $uti (sort {$a cmp $b} keys %{$Slot_Items{$slot_text}})
	foreach my $uti (sort {$a cmp $b} keys %{KSE::Data::GetItemData()})
	{
#		my @info	= @{$uti};
#		my $uti		= $info[0];				
#		$image		= $info[1];
#		$name		= $info[2];
#		$template	= $info[3];
#		$tag		= $info[4];
#		$path		= $info[5];

		# Find Target's race and compare.
#		print "self->type = " . $self->{'Type'} . ". Race is: ";
###		my $race = KSE::Functions::Saves::GetSaveData($self->{'Type'}, 'Race');
#		print "$race\n";
#		if($Slot_Items{$slot_text}{$uti}{Path} ne 'BIF') { print "Override file: $uti $Slot_Items{$slot_text}{$uti}{Template}\n"; }
#		
###		next if ($Slot_Items{$slot_text}{$uti}{Race} == 1 && $race == 5); # Item is for Humans only.
###		next if ($Slot_Items{$slot_text}{$uti}{Race} == 2 && $race == 6); # Item is for Droids only.
###		
###		$image		= $Slot_Items{$slot_text}{$uti}{Image};
###		$icon		= $Slot_Items{$slot_text}{$uti}{Icon};
###		$name		= $Slot_Items{$slot_text}{$uti}{Name};
###		$template	= $Slot_Items{$slot_text}{$uti}{Template};
###		$tag		= $Slot_Items{$slot_text}{$uti}{Tag};
###		$path		= $Slot_Items{$slot_text}{$uti}{Path};

		# Find Target's race and compare.
#		print "self->type = " . $self->{'Type'} . ". Race is: ";
		my $race = KSE::Data::GetData(KSE::GUI::Target::GetTarget(), 'Race');
#		print "$race\n";
#		if($Slot_Items{$slot_text}{$uti}{Path} ne 'BIF') { print "Override file: $uti $Slot_Items{$slot_text}{$uti}{Template}\n"; }
		
		next if ((KSE::Data::GetItemData($uti, 'EquipSlot') ne $slot_text) && (KSE::Data::GetItemData($uti, 'EquipSlot2') ne $slot_text));
		next if (KSE::Data::GetItemData($uti, 'Race') == 1 && $race == 5); # Item is for Humans only.
		next if (KSE::Data::GetItemData($uti, 'Race') == 2 && $race == 6); # Item is for Droids only.
		
#		$image		= KSE::Data::GetItemData($uti, 'Image');
		$icon		= KSE::Data::GetItemData($uti, 'Icon');
		$name		= KSE::Data::GetItemData($uti, 'Name');
		$template	= KSE::Data::GetItemData($uti, 'Template');
		$tag		= KSE::Data::GetItemData($uti, 'Tag');
		$path		= KSE::Data::GetItemData($uti, 'Path');

		#print "Processing $uti\n";
		$self->AddSlotItem($uti, $icon, $name, $template, $tag, $path);
	}

}

return 1;