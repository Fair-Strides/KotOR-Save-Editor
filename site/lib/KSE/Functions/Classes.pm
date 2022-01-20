#line 1 "KSE/Functions/Classes.pm"
package KSE::Functions::Classes;

use KSE::GUI::Feats;
use KSE::GUI::Main;

use KSE::Functions::Saves;
use KSE::Functions::Directory;

use Bioware::TLK;
use Bioware::TwoDA;

my $table = Bioware::TwoDA->new();
my %ClassInfo = undef;

sub Assign2da
{
	%ClassInfo = undef;
	$table->read2da(KSE::Functions::Directory::GetFile('classes.2da'));
}

sub GetClassName
{
	my $index = shift;
#	print "Index: $index - " . $table->get_cell($index, 'name') . "\n";
	return Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($index, 'name'));
}

sub GetCurrentClass
{
	my $target = shift;
	
	if(defined($ClassInfo{$target}{'CurrentClass'}) == 0)
	{ $ClassInfo{$target}{'CurrentClass'} = 1; }
	
	return $ClassInfo{$target}{'CurrentClass'};
}

sub SetCurrentClass
{
	my ($target, $class) = @_;
	
	$ClassInfo{$target}{'CurrentClass'} = $class;
}

sub GetLevelCap
{
	my $game = shift;
	
	if($game == 1)	{ return 20; }
	else			{ return 50; }
}

sub SetClassLevel
{
	my ($self, $class_index) = @_;
	
	my $target = $self->{'Type'};
	
#	print "Target: $target\nClass Index: $class_index\nLevel: " . $self->{'Data'}{'Class' . $class_index . 'Level'} . "\n";
	$ClassInfo{$target}{$class_index}{'Level'} = $self->{'Data'}{'Class' . $class_index . 'Level'};
	
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{$class_index}{'Level'}, $self->{'Type'}, 'Class' . $class_index, 'Level');
}

sub AddClass
{
	my ($self, $class_index) = @_;
	
	$ClassInfo{$self->{'Type'}}{$class_index}{'Class'} = $self->{'Data'}{'CurrentClass'};
	$self->{'Data'}{'Class' . $class_index . 'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($self->{'Data'}{'CurrentClass'}, 'name'));
	$self->{'Data'}{'Class' . $class_index . 'Level'} = 1;
	
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{$class_index}{'Class'}, $self->{'Type'}, 'Class' . $class_index, 'Class');
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{$class_index}{'Level'}, $self->{'Type'}, 'Class' . $class_index, 'Level');
}

sub RemoveClass
{
	my ($self, $class_index) = @_;
	
	if($class_index == 1)
	{
		$ClassInfo{$self->{'Type'}}{1}{'Class'}	= $ClassInfo{$self->{'Type'}}{2}{'Class'};
		$ClassInfo{$self->{'Type'}}{1}{'Level'}	= $ClassInfo{$self->{'Type'}}{2}{'Level'};
		
		$self->{'Data'}{'Class1Name'}		= $self->{'Data'}{'Class2Name'};
		$self->{'Data'}{'Class1Level'}	= $self->{'Data'}{'Class2Level'};
	}
	
	$ClassInfo{$self->{'Type'}}{2}{'Class'}	= undef;
	$ClassInfo{$self->{'Type'}}{2}{'Level'}	= 0;
	
	$self->{'Data'}{'Class2Name'}		= '<None>';
	$self->{'Data'}{'Class2Level'}	= 0;
	
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{1}{'Class'}, $self->{'Type'}, 'Class1', 'Class');
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{1}{'Level'}, $self->{'Type'}, 'Class1', 'Level');
	
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{2}{'Class'}, $self->{'Type'}, 'Class2', 'Class');
	KSE::Functions::Saves::SetSaveData($ClassInfo{$self->{'Type'}}{2}{'Level'}, $self->{'Type'}, 'Class2', 'Level');
}

sub GetClassList
{
	my @labels = ();

	for (my $i = 0; $i < $table->{rows}; $i++)
	{
		push(@labels, $i . ' - ' . Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($i, 'name')));
	}

	return @labels;
}
sub GetClasses
{
	my $target = shift;
	
#	print "Target: $target\nClass1: " . $ClassInfo{$target}{1}{'Class'} . "\nClass2: " . $ClassInfo{$target}{2}{'Class'} . "\n\n";
	my @labels = ();
#	for (my $i = 0; $i < $table->{rows}; $i++)
#	{
#		push(@labels, $i . ' - ' . Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($i, 'name')));
#	}

	push(@labels, '1 - ' . Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($ClassInfo{$target}{1}{'Class'}, 'name')));
	push(@labels, '2 - ' . Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($ClassInfo{$target}{2}{'Class'}, 'name')));
	
	return \@labels;
}

sub SetClassInfo
{
	my ($type, $index, $class, $level) = @_;
	
	$ClassInfo{$type}{$index}{'Class'} = $class;
	$ClassInfo{$type}{$index}{'Level'} = $level;
}

sub GetClassInfo
{
	my ($self, $class_index) = @_;
	
#	print "Type: " . $self->{'Type'} . "\nClass Index: $class_index\n";
#	print "Class: " . $ClassInfo{$self->{'Type'}}{$class_index}{'Class'} . "\n";
#	print "Level: " . $ClassInfo{$self->{'Type'}}{$class_index}{'Level'} . "\n";
	
	$self->{'Data'}{'Class' . $class_index . 'Name'} = Bioware::TLK::string_from_resref(KSE::Functions::Directory::GetGamePath(), $table->get_cell($ClassInfo{$self->{'Type'}}{$class_index}{'Class'}, 'name'));
	$self->{'Data'}{'Class' . $class_index . 'Level'} = $ClassInfo{$self->{'Type'}}{$class_index}{'Level'};
	if(defined($ClassInfo{$self->{'Type'}}{$class_index}{'Level'}) == 0)
	{
		$self->{'Data'}{'Class' . $class_index . 'Level'} = 0;
	}
	
	if($self->{'Data'}{'Class' . $class_index . 'Name'} eq 'Bad StrRef')
	{
		$self->{'Data'}{'Class' . $class_index . 'Name'} = "<None>";
	}
}

sub ChangeClass
{
	my ($target, $class) = @_;
	
	$ClassInfo{$target}{'CurrentClass'} = $class;
}

return 1;