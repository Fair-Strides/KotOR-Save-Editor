#line 1 "KSE/GUI/Directory.pm"
package KSE::GUI::Directory;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA    = qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::Functions::Directory;

use Tk;
use Tk::BrowseEntry;
use Tk::DialogBox;
use Tk::DirSelect;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::Radiobutton;
use Tk::Toplevel;

#use TkShortcuts;

my $CurrentPath = undef;
my $EditName	= undef;
my $EditPath	= undef;
my $EditMode	= undef;
my $EditCloud	= undef;
my $EditType	= undef;

my @column_sort_state = (1, 1, 1, 1);

sub new {
    #this is a generic constructor method

    my $invocant=shift;
	
    my $class=ref($invocant)||$invocant;
    my $self={ @_ };
	$self->{'Data'} = {};
	$self->{'GUI'} = {};
    bless $self,$class;
    return $self;
}

sub Create
{
	my ($self, $parent) = @_;
	
	$self->{'GUI'}{'Parent'} = $parent;

	$self->{'GUI'}{DirectoryWindow}	= $self->{'GUI'}{'Parent'}->Toplevel(-title=>'Editing Available Game Directories', -height=>400, -width=>711);
	$self->{'GUI'}{DirectoryWindow}->protocol('WM_DELETE_WINDOW', sub { $self->Close(); });
	$self->{'GUI'}{DirectoryWindow}->withdraw;
	
	$self->{'GUI'}{DirectoryFrame1}	= $self->{'GUI'}{DirectoryWindow}->Frame(-height=>390, -width=>590)->pack(-fill=>'both', -side=>'left', -padx=>10, -pady=>10);
	$self->{'GUI'}{DirectoryFrame2}	= $self->{'GUI'}{DirectoryWindow}->Frame(-height=>390, -width=>90)->pack(-fill=>'both', -side=>'right', -padx=>5, -pady=>10);
	
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Move Up',	-command=>sub { $self->MoveUp();	})->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Move Down',	-command=>sub { $self->MoveDown();	})->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Add',		-command=>sub { $self->AddPopup();	})->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Edit',		-command=>sub { $self->EditPopup();	})->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Remove',	-command=>sub { $self->Remove();	})->pack(-fill=>'x', -padx=>5, -pady=>5);
	$self->{'GUI'}{DirectoryFrame2}->Button(-text=>'Close',		-command=>sub { $self->Close();		})->pack(-fill=>'x', -padx=>5, -pady=>5);
	
	$self->{'GUI'}{DirectoryList}		= $self->{'GUI'}{DirectoryFrame1}->Scrolled('HList', -scrollbars=>'osoe', -font=>[-family=>'Lucida Console Regular', -size=>12], -height=>13, -width=>0, -columns=>4, -header=>1, -itemtype=>'text', -width=>64, -browsecmd=>\&selectPath)->pack(-fill=>'both');
#	$self->{'GUI'}{DirectoryList}->bind('<ButtonRelease-1>'=>sub { $CurrentPath = ($self->{'GUI'}{DirectoryList}->curselection)[0]; });
	
	$self->{'GUI'}{DirectoryList}->columnWidth(0, '-char', 20);
	$self->{'GUI'}{DirectoryList}->columnWidth(1, '-char', 5);
	$self->{'GUI'}{DirectoryList}->columnWidth(2, '-char', 10);
	$self->{'GUI'}{DirectoryList}->columnWidth(3, '');
	
	my $header_button0 = $self->{'GUI'}{DirectoryList}->Button(-anchor=>'center', -text=>'Name', -command=>[\&sortPath, $self, 0]);
	my $header_button1 = $self->{'GUI'}{DirectoryList}->Button(-anchor=>'center', -text=>'Game', -command=>[\&sortPath, $self, 1]);
	my $header_button2 = $self->{'GUI'}{DirectoryList}->Button(-anchor=>'center', -text=>'Uses Cloud', -command=>[\&sortPath, $self, 2]);
	my $header_button3 = $self->{'GUI'}{DirectoryList}->Button(-anchor=>'center', -text=>'Path', -command=>[\&sortPath, $self, 3]);
	
	$self->{'GUI'}{DirectoryList}->headerCreate(0, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button0);
	$self->{'GUI'}{DirectoryList}->headerCreate(1, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button1);
	$self->{'GUI'}{DirectoryList}->headerCreate(2, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button2);
	$self->{'GUI'}{DirectoryList}->headerCreate(3, -itemtype=>'window', -borderwidth=>-2, -widget=>$header_button3);
	
	# The window for adding/editing game directories
#	$self->{'GUI'}{DirectoryWindow2}	= $self->{'GUI'}{DirectoryWindow}->Toplevel(-title=>'Editing Game Directory', -height=>400, -width=>300);
	$self->{'GUI'}{DirectoryWindow2}	= $self->{'GUI'}{'Parent'}->DialogBox(-title=>'Editing Game Directory', -buttons=>['Ok', 'Cancel'], -default_button=>'Ok', -cancel_button=>'Cancel', -command=>sub { my $button = shift; Process_Button($self, $button); });
	$self->{'GUI'}{DirectoryWindow2}->protocol('WM_DELETE_WINDOW', sub { Process_Button($self, 'Cancel'); });
#	$self->{'GUI'}{DirectoryWindow2}->withdraw;

	$self->{'GUI'}{DirectoryWindow2_Frame1} = $self->{'GUI'}{DirectoryWindow2}->add('Frame', -height=>30, -width=>250)->pack(-padx=>25, -pady=>2);
	$self->{'GUI'}{DirectoryWindow2_Frame2} = $self->{'GUI'}{DirectoryWindow2}->add('Frame', -height=>30, -width=>250)->pack(-padx=>25, -pady=>2);
	$self->{'GUI'}{DirectoryWindow2_Frame3} = $self->{'GUI'}{DirectoryWindow2}->add('Frame', -height=>30, -width=>250)->pack(-padx=>25, -pady=>2);
	$self->{'GUI'}{DirectoryWindow2_Frame4} = $self->{'GUI'}{DirectoryWindow2}->add('Frame', -height=>30, -width=>250)->pack(-padx=>25, -pady=>2);
#	$self->{'GUI'}{DirectoryWindow2_Frame5} = $self->{'GUI'}{DirectoryWindow2}->add('Frame', -height=>30, -width=>250)->pack(-padx=>25, -pady=>10);

	$self->{'GUI'}{DirectoryWindow2_Frame1}->Label(-text=>'Game Name: ', -anchor=>'w', -justify=>'left', -width=>14)->pack(-side=>'left', -anchor=>'w');
	$self->{'GUI'}{DirectoryWindow2_Frame1}->Entry(-textvariable=>\$EditName, -width=>60)->pack(-padx=>10, -side=>'right');
	
	$self->{'GUI'}{DirectoryWindow2_Frame2}->Label(-text=>'Game Path: ', -anchor=>'w', -justify=>'left', -width=>14)->pack(-side=>'left', -anchor=>'w');
	$self->{'GUI'}{DirectoryWindow2_Frame2}->Button(-text=>'...', -font=>[-size=>10], -command=>sub { $self->BrowseForFolder(); })->pack(-side=>'right');
	$self->{'GUI'}{DirectoryWindow2_Frame2}->Entry(-textvariable=>\$EditPath, -width=>56)->pack(-padx=>10, -side=>'right');
	
	$self->{'GUI'}{DirectoryWindow2_Frame3}->Label(-text=>'Game Mode: ')->pack(-side=>'left');
	$self->{'GUI'}{DirectoryWindow2_Frame3}->Radiobutton(-text=>'KotOR 1', -value=>1, -variable=>\$EditMode)->pack(-padx=>20, -side=>'left');
	$self->{'GUI'}{DirectoryWindow2_Frame3}->Radiobutton(-text=>'KotOR 2', -value=>2, -variable=>\$EditMode)->pack(-padx=>20, -side=>'right');
	
	$self->{'GUI'}{DirectoryWindow2_Frame4}->Label(-text=>'Use Cloud Saves: ')->pack(-side=>'left');
	$self->{'GUI'}{DirectoryWindow2_Frame4}->Radiobutton(-text=>'No', -value=>0, -variable=>\$EditCloud)->pack(-side=>'right', -anchor=>'w', -padx=>20);
	$self->{'GUI'}{DirectoryWindow2_Frame4}->Radiobutton(-text=>'Yes', -value=>1, -variable=>\$EditCloud)->pack(-side=>'right', -anchor=>'e', -padx=>20);
	
#	$self->{'GUI'}{DirectoryWindow2_Frame5}->Button(-text=>'Ok', -font=>[-size=>15], -command=>sub { $self->Confirm(); })->pack(-side=>'left');
#	$self->{'GUI'}{DirectoryWindow2_Frame5}->Button(-text=>'Cancel', -font=>[-size=>15], -command=>sub { $self->Cancel(); })->pack(-side=>'left');
	
	$self->{'GUI'}{DirSelect} = $self->{'GUI'}{DirectoryWindow2}->DirSelect(-title=>'Browse for KotOR / TSL Directory...');
	$self->{'GUI'}{DirectoryWindow}->withdraw;
	$self->{'GUI'}{DirectoryWindow2}->withdraw;
	
	return $self;
}

sub sortPath
{
	my $self	= shift;
	my $col		= shift;

#	print "Self: $self\nCol: $col\n";
	my @entries = $self->{'GUI'}{DirectoryList}->info('children');
	my @to_be_sorted =();

	foreach my $entry(@entries)
	{
#		print "Entry $entry\n";
		push @to_be_sorted,
		[
			$self->{'GUI'}{DirectoryList}->itemCget($entry, 0, 'text'),
			$self->{'GUI'}{DirectoryList}->itemCget($entry, 1, 'text'),
			$self->{'GUI'}{DirectoryList}->itemCget($entry, 2, 'text'),
			$self->{'GUI'}{DirectoryList}->itemCget($entry, 3, 'text'),
		];
	}

	my @sorted = ();
	if($column_sort_state[$col] == 0)
	{
		$column_sort_state[$col] = 1;
		@sorted = sort {	$a->[$col] cmp $b->[$col] } @to_be_sorted;# || # primary sort ascii
#						$a->[1] <=> $b->[1]          # secondary sort numeric
#					  } @to_be_sorted;
	}
	else
	{
		$column_sort_state[$col] = 0;
		@sorted = sort {	$b->[$col] cmp $a->[$col] } @to_be_sorted;
	}
	
	my $entry = 0;
	foreach my $aref (@sorted)
	{
#		print "Entry $entry: ", $aref->[0] , ' ' , $aref->[1] , ' ' , $aref->[2], ' ', $aref->[3], "\n";
		$self->{'GUI'}{DirectoryList}->itemConfigure($entry, 0, 'text' => $aref->[0]);  
		$self->{'GUI'}{DirectoryList}->itemConfigure($entry, 1, 'text' => $aref->[1]); 
		$self->{'GUI'}{DirectoryList}->itemConfigure($entry, 2, 'text' => $aref->[2]); 
		$self->{'GUI'}{DirectoryList}->itemConfigure($entry, 3, 'text' => $aref->[3]); 
		$entry++;
	}
	
}

sub selectPath
{
	$CurrentPath = shift;
}

sub Process_Button
{
	my ($self, $button) = @_;
	
	if($button eq 'Ok') { $self->Confirm(); }
	else				{ $self->Cancel(); }
}

sub ShowDirectory
{
	my $self = shift;
	
	$self->{'GUI'}{DirectoryWindow}->Popup(-popover=>undef, -popanchor=>'c', -overanchor=>'c');
}

sub ShowAddFirstPath
{
	my $self = shift;
		
	$EditName	= '';
	$EditPath	= '';
	$EditMode	= 1;
	$EditCloud	= 0;
	$EditType	= 'Add';
	$self->{'GUI'}{DirectoryWindow2}->configure(-title=>'Adding the First Game Directory');

	my $answer = $self->{'GUI'}{DirectoryWindow2}->cget('-title');
	
	$self->{'GUI'}{DirectoryWindow2}->Show(-popover=>undef, -popanchor=>'c', -overanchor=>'c');
	$self->{'GUI'}{DirectoryWindow2}->focus;
#	$self->{'GUI'}{DirectoryWindow2}->Popup(-popover=>undef, -popanchor=>'c', -overanchor=>'c');
#	$self->{'GUI'}{DirectoryWindow2}->grab;
}

# Directory Window Commands
sub MoveUp
{
	my $self = shift;
	return if $CurrentPath == 0;
	
	KSE::Functions::Directory::MoveUp($CurrentPath);
	
	$self->RepopulateList();
}

sub MoveDown
{
	my $self = shift;
	return if $CurrentPath == (KSE::Functions::Directory::GetPathCount() - 1);

	KSE::Functions::Directory::MoveDown($CurrentPath);
	
	$self->RepopulateList();
}

sub AddPopup
{
	my $self = shift;
	
	$self->{'GUI'}{DirectoryWindow2}->configure(-title=>'Adding Game Directory');
	$EditType = 'Add';
	$EditName	= '';
	$EditMode	= 1;
	$EditCloud	= 0;
	$EditPath	= '';
	
	$self->{'GUI'}{DirectoryWindow2}->Show(-global, -popover=>undef, -popanchor=>'c', -overanchor=>'c');
#	$self->{'GUI'}{DirectoryWindow2}->Popup(-popover=>undef, -popanchor=>'c', -overanchor=>'c');
#	$self->{'GUI'}{DirectoryWindow2}->grab;
}

sub EditPopup
{
	my $self = shift;
	
	print "CurrentPath: $CurrentPath\n";
	$self->{'GUI'}{DirectoryWindow2}->configure(-title=>'Editing Game Directory');
	$EditType	= 'Edit';
	$EditName	= KSE::Functions::Directory::GetPathName($CurrentPath);
	$EditMode	= KSE::Functions::Directory::GetPathGame($CurrentPath);
	$EditCloud	= KSE::Functions::Directory::GetPathCloud($CurrentPath);
	$EditPath	= KSE::Functions::Directory::GetPathPath($CurrentPath);
	
	$self->{'GUI'}{DirectoryWindow2}->Show(-global, -popover=>undef, -popanchor=>'c', -overanchor=>'c');
#	$self->{'GUI'}{DirectoryWindow2}->Popup(-popover=>undef, -popanchor=>'c', -overanchor=>'c');
#	$self->{'GUI'}{DirectoryWindow2}->grab;
}

sub Remove
{
	my $self = shift;
	$self->{'GUI'}{DirectoryList}->delete('entry', $CurrentPath);

	KSE::Functions::Directory::RemovePath($CurrentPath);
}

sub Close
{
	my $self = shift;
#	$self->{'GUI'}{DirectoryList}->activate(0);
	$self->{'GUI'}{DirectoryWindow}->withdraw;
	
	KSE::GUI::Main::remake_game_menuitems();
}

sub RepopulateList
{
	my $self = shift;
	$self->{'GUI'}{DirectoryList}->delete('all');
	
	my $count = KSE::Functions::Directory::GetPathCount();
	if($count >= 0)
	{
		foreach my $key (0 .. $count)
		{
			next if ($key == $count && $count > 0);
			
			my $cloud = KSE::Functions::Directory::GetPathCloud($key);
			if($cloud == 0)	{ $cloud = "No";	}
			else			{ $cloud = "Yes";	}
			
			$self->{'GUI'}{DirectoryList}->add($key);
			$self->{'GUI'}{DirectoryList}->itemCreate($key, 0, -text=>KSE::Functions::Directory::GetPathName($key));
			$self->{'GUI'}{DirectoryList}->itemCreate($key, 1, -text=>'    '  . KSE::Functions::Directory::GetPathGame($key));
			$self->{'GUI'}{DirectoryList}->itemCreate($key, 2, -text=>'         ' . $cloud);
			$self->{'GUI'}{DirectoryList}->itemCreate($key, 3, -text=>KSE::Functions::Directory::GetPathPath($key));
			
#			print "$key Path: " . KSE::Functions::Directory::GetPathPath($key) . "\nPath2: " . $self->{'GUI'}{DirectoryList}->itemCget($key, 3, 'text') . "\n\n";
		}
	}
}

sub Confirm
{
	my $self = shift;
	
	my $cloud = $EditCloud;
	if($cloud == 0)	{ $cloud = "No";	}
	else			{ $cloud = "Yes";	}
	
	if($EditType eq 'Add')
	{
		my $key = KSE::Functions::Directory::AddPath($EditName, $EditMode, $EditCloud, $EditPath);
		
		$self->{'GUI'}{DirectoryList}->add($key);
		$self->{'GUI'}{DirectoryList}->itemCreate($key, 0, -text=>KSE::Functions::Directory::GetPathName($key));
		$self->{'GUI'}{DirectoryList}->itemCreate($key, 1, -text=>'    '  . KSE::Functions::Directory::GetPathGame($key));
		$self->{'GUI'}{DirectoryList}->itemCreate($key, 2, -text=>'         ' . $cloud);
		$self->{'GUI'}{DirectoryList}->itemCreate($key, 3, -text=>KSE::Functions::Directory::GetPathPath($key));
		
		$self->RepopulateList;
	}
	else
	{
		KSE::Functions::Directory::EditPath($CurrentPath, $EditName, $EditMode, $EditCloud, $EditPath);
			
		$self->{'GUI'}{DirectoryList}->delete('entry', $CurrentPath);
		
#		if($CurrentPath >= scalar ($self->{'GUI'}{DirectoryList}->info('children')))
#		{
#			$self->{'GUI'}{DirectoryList}->add($CurrentPath, -at=>'end');
#		}
#		elsif($CurrentPath > 0)
#		{
#			$self->{'GUI'}{DirectoryList}->add($CurrentPath, -before=>($CurrentPath - 1));
#		}
#		else
#		{
#			$self->{'GUI'}{DirectoryList}->add($CurrentPath, -at=>0);
#		}
		$self->{'GUI'}{DirectoryList}->add($CurrentPath, -at=>$CurrentPath);
		$self->{'GUI'}{DirectoryList}->itemCreate($CurrentPath, 0, -text=>KSE::Functions::Directory::GetPathName($CurrentPath));
		$self->{'GUI'}{DirectoryList}->itemCreate($CurrentPath, 1, -text=>'    '  . KSE::Functions::Directory::GetPathGame($CurrentPath));
		$self->{'GUI'}{DirectoryList}->itemCreate($CurrentPath, 2, -text=>'         ' . $cloud);
		$self->{'GUI'}{DirectoryList}->itemCreate($CurrentPath, 3, -text=>KSE::Functions::Directory::GetPathPath($CurrentPath));
	}
	
	$self->{'GUI'}{DirectoryWindow2}->grabRelease;
	$self->{'GUI'}{DirectoryWindow2}->withdraw;

}

sub Cancel
{
	my $self = shift;
	$EditName = '';
	$EditPath = '';
	
	$self->{'GUI'}{DirectoryWindow2}->grabRelease;
	$self->{'GUI'}{DirectoryWindow2}->withdraw;
}

sub BrowseForFolder
{
	my $self = shift;
#	$EditPath = $self->{'GUI'}{DirectoryWindow2}->chooseDirectory(-parent=>$self->{'GUI'}{DirectoryWindow2}, -title=>'Browse for KotOR / TSL Directory...', -mustexist=>1);
	$EditPath = $self->{'GUI'}{DirSelect}->Show();
#	$EditPath = tkShortcuts::superdirchoose();
}

return 1;