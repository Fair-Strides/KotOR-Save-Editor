#line 1 "KSE/Functions/Journal.pm"
package KSE::Functions::Journal;

use KSE::Functions::Saves;
use KSE::Functions::Directory;

use Bioware::GFF;

my $jrl_gff = Bioware::GFF->new();
my $pty_gff = Bioware::GFF->new();
my %QuestInfo = undef;

sub AssignJRL
{
	my ($game, $pty_gff_path) = @_;
	
	$pty_gff->read_gff_file($pty_gff_path);
	
	# Get the Game's global.jrl file
	if($game == 1)
	{
		$jrl_gff->read_gff_file(KSE::Functions::Directory::GetFile('global.jrl', "data\\_newbif.bif"));
	}
	else
	{
		$jrl_gff->read_gff_file(KSE::Functions::Directory::GetFile('global.jrl', "data\\dialogs.bif"));
	}
	
	my $jrl_entries_arr_ref		= $pty_gff->{Main}{Fields}[$pty_gff->{Main}->fbl('JNL_Entries')]{Value};
	my $jrl_categories_arr_ref	= $jrl_gff->{Main}{Fields}{Value};
	
	%QuestInfo = undef;
	$QuestInfo{'Count'} = 0;
	
	#now loop through each journal category
	my $p_ix = -1;
	for my $jrl_entry (@$jrl_entries_arr_ref)
	{
		$p_ix++;
		$QuestInfo{'Count'} += 1;
		
		my $this_plot_id	= lc($jrl_entry->{Fields}[$jrl_entry->fbl('JNL_PlotID')]{Value});
		my $this_state		= $jrl_entry->{Fields}[$jrl_entry->fbl('JNL_State')]{Value};

		$QuestInfo{$p_ix}{'Tag'}	= $this_plot_id;
		$QuestInfo{$p_ix}{'State'}	= $this_state;
		
		#and compare it the global.jrl, synching up using Tag value
		my $ix=0;
		for my $jrl_category (@$jrl_categories_arr_ref)
		{
			my $tag	= lc($jrl_category->{Fields}[$jrl_category->fbl('Tag')]{Value});
			if ($tag eq $this_plot_id)
			{
				#get the name from the global journal when synch occurs
				my $this_name;
				my $this_name_strref = $jrl_category->{Fields}[$jrl_category->fbl('Name')]{Value}{StringRef};
				if ($this_name_strref == -1)
				{
					$this_name = $jrl_category->{Fields}[$jrl_category->fbl('Name')]{Value}{Substrings}[0]{Value};
				}
				else
				{
					$this_name = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $this_name_strref);
				}
				
				$QuestInfo{$p_ix}{'Name'}	= $this_name;				
				
				#now seek out where in this journal category the player has reached, synching on plot_id
				my $jrl_entries_arr_ref = $jrl_category->{Fields}[$jrl_category->fbl('EntryList')]{Value};
				my @choices = ();
				for my $jrl_entry (@$jrl_entries_arr_ref)
				{
					my $jrl_id = $jrl_entry->{Fields}[$jrl_entry->fbl('ID')]{Value};
					
					my $this_text;
					my $this_text_strref = $jrl_entry->{Fields}[$jrl_entry->fbl('Text')]{Value}{StringRef};
					if ($this_text_strref == -1)
					{
						$this_text = $jrl_entry->{Fields}[$jrl_entry->fbl('Text')]{Value}{'Substrings'}[0]{Value};
					}
					else
					{
						$this_text = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $this_text_strref);
					}
					
					$QuestInfo{$p_ix}{'Entries'}{$jrl_id} = $this_text;
#					print "Adding $jrl_id to Quest $p_ix: $this_name\n";
					push(@choices, $jrl_id);
				} #the last (1) jumps to here
				
				$QuestInfo{$p_ix}{'Choices'} = \@choices;
#				print "Array: @choices\t" . scalar (@choices) . "\t" . join("_", @choices) . "\n";
#				last; #2
			}
			$ix++;
		} #the last (2) jumps to here
	}
	
	foreach(GetQuestList())
	{
		KSE::GUI::Journal::AddQuest(KSE::GUI::Main::GetPanelSelf('Journal'), $_);
	}
}

sub GetQuestName
{
	my $index = shift;
#	print "Index: $index - " . $table->get_cell($index, 'name') . "\n";
	return $QuestInfo{$index}{'Name'};
}

sub GetQuestState
{
	my $index = shift;
	
	return $QuestInfo{$index}{'State'};
}

sub SetQuestState
{
#	print "Array:\n\t" . join("\n\t", @_) . ".\n";
	my ($index, $state) = @_;
	
	$QuestInfo{$index}{'State'} = $state;
}

sub GetQuestEntries
{
	my $index = shift;
	
#	print "Index $index: $QuestInfo{$index}{'Choices'}.\n";
	return $QuestInfo{$index}{'Choices'};
}

sub GetEntryText
{
	my ($index, $entry) = @_;
	
	return $QuestInfo{$index}{'Entries'}{$entry};
}

sub GetCurrentQuest
{
	if(defined($QuestInfo{'CurrentQuest'}) == 0)
	{ $QuestInfo{'CurrentQuest'} = undef; }
	
	return $QuestInfo{'CurrentQuest'};
}

sub SetCurrentQuest
{
	my $quest = shift;
	
	$QuestInfo{'CurrentQuest'} = $quest;
}

sub GetQuestList
{
	my @labels = ();

	for (my $i = 0; $i < $QuestInfo{'Count'}; $i++)
	{
		push(@labels, $QuestInfo{$i}{'Name'});
	}

	return @labels;
}

sub SaveJRL
{
	my $path = shift;
	
	$pty_gff->read_gff_file($path);
	
	my $jrl_arr_ref = $pty_gff->{Main}{Fields}[$pty_gff->{Main}->fbl('JNL_Entries')]{Value};
	
	my $ix = -1;
	foreach my $jrl_entry (@$jrl_arr_ref)
	{
		$ix++;
		$jrl_entry->{'Fields'}[$jrl_entry->fbl('JNL_State')]{Value} = $QuestInfo{$ix}{'State'};
	}
	
	$pty_gff->{Main}{Fields}[$pty_gff->{Main}->fbl('JNL_Entries')]{Value} = $jrl_arr_ref;
	$pty_gff->write_gff_file($path);
}

return 1;