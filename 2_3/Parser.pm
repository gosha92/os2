package Parser;
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw( parse );

use v5.10.1;
use Data::Dumper;
$Data::Dumper::Terse = 1;

# Итоговое разбиение
sub mysplit($) {
	my $s = shift;
	my $a;

	($a, $r) = split1($$s);
	if ($r) {
		$$s = $a;
		return 1;
	} else {
		$$s = $a->[0];
	}

	($a, $r) = split2($$s);
	if ($r) {
		$$s = $a;
		return 1;
	} else {
		$$s = $a->[0];
	}

	($a, $r) = split3($$s);
	if ($r) {
		$$s = $a;
		return 1;
	} else {
		$$s = $a->[0];
	}

	($a, $r) = split4($$s);
	if ($r) {
		$$s = $a;
		return 1;
	} else {
		$$s = $a->[0];
	}

	my $bs = braces($$s);
	$$s = $bs;
	return 0;
}

# Разбивает строку по ;
sub split1 {
	my $s = shift;
	my @s = split //, $s;

	my $brace_count = 0;
	my @tokens;
	my $token = '';
	for my $chr (@s) {
		given ($chr) {
			when ('(') {
				++$brace_count;
				continue;
			}
			when (')') {
				--$brace_count;
				continue;
			}
			when (';') {
				continue if $brace_count;
				push @tokens, &trim($token);
				$token = '';
			}
			default {
				$token .= $chr;
			}
		}
	}
	push @tokens, &trim($token);

	my $result = 0;
	unless (scalar @tokens == 1) {
		unshift @tokens, ';';
		$result = 1;
	}

	return \@tokens, $result;
}

# Разбивает строку по <
sub split2 {
	my $s = shift;
	my @s = split //, $s;

	my $brace_count = 0;
	my @tokens;
	my $token = '';
	my $last = 0;
	for my $chr (@s) {
		if ($last) {
			$token .= $chr;
			next;
		}
		given ($chr) {
			when ('(') {
				++$brace_count;
				continue;
			}
			when (')') {
				--$brace_count;
				continue;
			}
			when ('<') {
				continue if $brace_count;
				push @tokens, &trim($token);
				$token = '';
				$last = 1;
			}
			default {
				$token .= $chr;
			}
		}
	}
	push @tokens, &trim($token);

	my $result = 0;
	unless (scalar @tokens == 1) {
		unshift @tokens, '<';
		$result = 1;
	}

	return \@tokens, $result;
}

# Разбивает строку по >
sub split3 {
	my $s = shift;
	my @s = split //, $s;

	my $brace_count = 0;
	my @tokens;
	my $token = '';
	my $last = 0;
	for my $chr (@s) {
		if ($last) {
			$token .= $chr;
			next;
		}
		given ($chr) {
			when ('(') {
				++$brace_count;
				continue;
			}
			when (')') {
				--$brace_count;
				continue;
			}
			when ('>') {
				continue if $brace_count;
				push @tokens, &trim($token);
				$token = '';
				$last = 1;
			}
			default {
				$token .= $chr;
			}
		}
	}
	push @tokens, &trim($token);

	my $result = 0;
	unless (scalar @tokens == 1) {
		unshift @tokens, '>';
		$result = 1;
	}

	return \@tokens, $result;
}

# Разбивает строку по |
sub split4 {
	my $s = shift;
	my @s = split //, $s;

	my $brace_count = 0;
	my @tokens;
	my $token = '';
	for my $chr (@s) {
		given ($chr) {
			when ('(') {
				++$brace_count;
				continue;
			}
			when (')') {
				--$brace_count;
				continue;
			}
			when ('|') {
				continue if $brace_count;
				push @tokens, &trim($token);
				$token = '';
			}
			default {
				$token .= $chr;
			}
		}
	}
	push @tokens, &trim($token);

	my $result = 0;
	unless (scalar @tokens == 1) {
		unshift @tokens, '|';
		$result = 1;
	}

	return \@tokens, $result;
}

# Обрезает пробелы по краям
sub trim {
	my $s = shift;
	$s =~ s/^\s*(\S)/\1/;
	$s =~ s/(\S)\s*$/\1/;
	return $s;
}

# Убирает скобки по краям
sub braces {
	my $s = shift;
	if ($s =~ /^\(/ && $s =~ /\)$/) {
		$s =~ s/^\(//;
		$s =~ s/\)$//;
	}
	return $s;
}




sub parse {

	my $s = shift;
	my @q = ( \$s );

	while ($t = shift @q) {
		my $res = mysplit($t);
		if ($res) {
			for (@{$$t}) {
				next if $_ eq ';';
				next if $_ eq '|';
				next if $_ eq '>';
				next if $_ eq '<';
				next unless $_ =~ /[\;\|\<\>]/;
				push @q, \$_;
			}
		} else {
			next unless $$t =~ /[\;\|\<\>]/;
			push @q, $t;
		}
	}

	# print 'RESULT';
	# print Dumper($s);
	return $s;
}



1;