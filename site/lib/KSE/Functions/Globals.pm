#line 1 "KSE/Functions/Globals.pm"
package KSE::Functions::Globals;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA	= qw(Exporter);

# export functions/variables
@EXPORT = qw(  );

use KSE::GUI::Globals;
use Bioware::GFF;

my %Globals = ();
my $CurrentGlobal	= undef;

sub ReadGlobals
{
	my $GlobalVarsRes = shift;

	%Globals = ();
	$CurrentGlobal = undef;
	
	my $catboolean_ix	= $GlobalVarsRes->{Main}->fbl('CatBoolean');
	my $catnumber_ix	= $GlobalVarsRes->{Main}->fbl('CatNumber');
	my $catstring_ix	= $GlobalVarsRes->{Main}->fbl('CatString');
	my $catlocation_ix	= $GlobalVarsRes->{Main}->fbl('CatLocation');
	
	my $catboolean	= $GlobalVarsRes->{Main}{Fields}[$catboolean_ix]{'Value'};
	my $catnumber	= $GlobalVarsRes->{Main}{Fields}[$catnumber_ix]{'Value'};
	my $catstring	= $GlobalVarsRes->{Main}{Fields}[$catstring_ix]{'Value'};
	my $catlocation	= $GlobalVarsRes->{Main}{Fields}[$catlocation_ix]{'Value'};
	
	# Booleans
	my @globaldata = split(//, unpack('B*', $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValBoolean')]{'Value'}));

	$Globals{'Count'}{'Boolean'} = scalar @{$catboolean};
#	print "Count for Booleans: " . $Globals{'Count'}{'Boolean'} . "\n";
	for (my $i = 0; $i < scalar @{$catboolean}; $i++)
	{
#		print "Key: " . $GlobalVarsRes->{Main}{Fields}[$catboolean_ix]{'Value'}[$i]{'Fields'}{'Value'} . ".\tValue: " . $globaldata[$i] . "\n";
		
		$Globals{'Boolean'}{$GlobalVarsRes->{Main}{Fields}[$catboolean_ix]{'Value'}[$i]{'Fields'}{'Value'}} = $globaldata[$i];
#		$Globals{'Boolean'}{Index}{$i} = $catboolean[$i]{'Fields'}{'Value'};
		$Globals{'Boolean'}{Index}{$i} = $GlobalVarsRes->{Main}{Fields}[$catboolean_ix]{'Value'}[$i]{'Fields'}{'Value'};
	}
	
	# Numbers
	@globaldata = unpack('C' . scalar @{$catnumber}, $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValNumber')]{'Value'});
	
	$Globals{'Count'}{'Number'} = scalar @{$catnumber};
	for (my $i = 0; $i < scalar @{$catnumber}; $i++)
	{
		$Globals{'Number'}{$GlobalVarsRes->{Main}{Fields}[$catnumber_ix]{'Value'}[$i]{'Fields'}{'Value'}} = $globaldata[$i];
#		$Globals{'Number'}{Index}{$i} = $catnumber[$i]{'Fields'}{'Value'};
		$Globals{'Number'}{Index}{$i} = $GlobalVarsRes->{Main}{Fields}[$catnumber_ix]{'Value'}[$i]{'Fields'}{'Value'};
	}
	
	# Strings
	@globaldata = @{$GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValString')]{'Value'}};
	
	$Globals{'Count'}{'String'} = scalar @{$catstring};
	for (my $i = 0; $i < scalar @{$catstring}; $i++)
	{
		$Globals{'String'}{$GlobalVarsRes->{Main}{Fields}[$catstring_ix]{'Value'}[$i]{'Fields'}{'Value'}} = $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValString')]{'Value'}[$i]{'Fields'}{'Value'};
#		$Globals{'String'}{Index}{$i} = $catstring[$i]{'Fields'}{'Value'};
		$Globals{'String'}{Index}{$i} = $GlobalVarsRes->{Main}{Fields}[$catstring_ix]{'Value'}[$i]{'Fields'}{'Value'};
	}
	
	# Locations
	@globaldata = unpack('f600', $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValLocation')]{'Value'});
	
	$Globals{'Count'}{'Location'} = scalar @{$catlocation};
	for (my $i = 0; $i < scalar @{$catlocation}; $i++)
	{
#		print "Location of $i: " . $GlobalVarsRes->{Main}{Fields}[$catlocation_ix]{'Value'}[$i]{'Fields'}{'Value'} . "\n";
#		print "\tX: " . $globaldata[$i * 12] . "\n";
#		print "\tY: " . $globaldata[($i * 12) + 1] . "\n";
#		print "\tZ: " . $globaldata[($i * 12) + 2] . "\n";
#		print "\tOri_X: " . $globaldata[($i * 12) + 3] . "\n";
#		print "\tOri_Y: " . $globaldata[($i * 12) + 4] . "\n\n";
		$Globals{'Location'}{$GlobalVarsRes->{Main}{Fields}[$catlocation_ix]{'Value'}[$i]{'Fields'}{'Value'}} = [
		$globaldata[$i * 12],
		$globaldata[($i * 12) + 1],
		$globaldata[($i * 12) + 2],
		KSE::Functions::Main::GetOrientationDegrees($globaldata[($i * 12) + 3], $globaldata[($i * 12) + 4])];
#		$Globals{'Location'}{Index}{$i} = $catlocation[$i]{'Fields'}{'Value'};
		$Globals{'Location'}{Index}{$i} = $GlobalVarsRes->{Main}{Fields}[$catlocation_ix]{'Value'}[$i]{'Fields'}{'Value'};
	}
}

sub SaveGlobals
{
	my ($GlobalVarsRes, $path_to_save) = @_;
	
	my $catboolean = $GlobalVarsRes->{Main}->fbl('ValBoolean');
	my $catnumber = $GlobalVarsRes->{Main}->fbl('ValNumber');
	my $catstring = $GlobalVarsRes->{Main}->fbl('ValString');
	my $catlocation = $GlobalVarsRes->{Main}->fbl('ValLocation');
	
	# Booleans
	my $globaldata = undef;
	# split(//, unpack('B*', $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValBoolean')]{'Value'}));

	for (my $i = 0; $i < $Globals{'Count'}{'Boolean'}; $i++)
	{
		$globaldata .= $Globals{'Boolean'}{$Globals{'Boolean'}{Index}{$i}};
	}
	
	$GlobalVarsRes->{Main}{Fields}[$catboolean]{Value} = pack('B' . $Globals{'Count'}{'Boolean'}, $globaldata);
	
	# Numbers
	$globaldata = undef;
	# unpack('C' . scalar @{$catnumber}, $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValNumber')]{'Value'});
	
	for (my $i = 0; $i < $Globals{'Count'}{'Number'}; $i++)
	{
		$globaldata .= $Globals{'Number'}{$Globals{'Number'}{Index}{$i}};
	}
	
	$GlobalVarsRes->{Main}{Fields}[$catnumber]{Value} = pack('C' . $Globals{'Count'}{'Number'}, $globaldata);
	
	# Strings
	$globaldata = undef;
	# @{$GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValString')]{'Value'}};
	
	for (my $i = 0; $i < $Globals{'Count'}{'String'}; $i++)
	{
		$GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValString')]{'Value'}[$i]{'Fields'}{'Value'} = $Globals{'String'}{$Globals{'String'}{Index}{$i}};
	}
	
	# Locations
	$globaldata = undef;
	# unpack('f600', $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('ValLocation')]{'Value'});
	
	for (my $i = 0; $i < $Globals{'Count'}{'Location'}; $i++)
	{
#		print "Handling Location $i - " . $Globals{'Location'}{'Index'}{$i} . "\n";
		my $f = -1;
		my $location = $Globals{'Location'}{$Globals{'Location'}{'Index'}{$i}};
		foreach my $value (@$location)
		{
			$f++;
#			print "F: $f $value\n";
			
			if($f == 3)
			{
				my @values = KSE::Functions::Main::GetOrientationRadians($value);
#				print "Values for Location $i " . $Globals{'Location'}{'Index'}{$i} . ":\tX: " . $values[0] . ", Y: " . $values[1] . "\n";
				$globaldata .= pack('f2', @values);
			}
			else
			{
				$globaldata .= pack('f', $value);
			}
		}
		
		$globaldata .= pack('f7', 0, 0, 0, 0, 0, 0, 0);
	}
	
	for (my $h = $Globals{'Count'}{'Location'}; $h < 50; $h++)
	{
		$globaldata .= pack('f12', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	}
	
	$GlobalVarsRes->{Main}{Fields}[$catlocation]{Value} = $globaldata;
	
	$GlobalVarsRes->write_gff_file($path_to_save);
}

sub GetGlobalValue
{
	my ($name, $type) = @_;
	
	return $Globals{$type}{$name};
}

sub SetGlobalValue
{
	my ($name, $type, $value) = @_;
	
	$Globals{$type}{$name} = $value;
}

sub GetGlobals
{
	my $type = shift;
#	print "Type: $type\nCount: " . scalar (keys %{$Globals{$type}}) . "\n";
#	my $ix = $GlobalVarsRes->{Main}{Fields}[$GlobalVarsRes->{Main}->fbl('Cat' . $type)]{'Value'};
	
	my @entries = ();
	
	foreach (sort {$a cmp $b} keys %{$Globals{$type}})
	{
		next if $_ eq 'Index';
#		print "Key: $_.\tValue: " . $Globals{$type}{$_} . "\n";
		push (@entries, $_);
	}
	
#	foreach (my $i = 0; $i < scalar @{$ix}; $i++)
#	{
#		push (@entries, $ix[$i]{'Fields'}{'Value'});
#	}
	
	return @entries;
}

return 1;