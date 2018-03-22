use strict;
use warnings;
use utf8;
use Encode;
#use Data::Printer;

my $project_directory = $ARGV[0];
my $output_directory = $ARGV[1];
my $max_recursion_deep = 10;
my $recursion_deep = 0;
unless($project_directory){
    print "please input project directory.\n";
    print "ex. perl generate_storyboard.pl myproject_directory output_storyboard_directory\n";
    exit;
}
unless($output_directory){
    print "please input output_storyboard directory.\n";
    print "ex. perl generate_storyboard.pl myproject_directory output_storyboard_directory\n";
    exit;
}

my $scenario_directory = $project_directory.'/data/scenario/';
my $bgimage_directory = $project_directory.'/data/bgimage';
# directory files to @scenario_files
my @scenario_files = ();
opendir(DIRHANDLE, $scenario_directory);
print $scenario_directory."\n";
foreach(readdir(DIRHANDLE)){
    next if /^\.{1,2}|~$/;
    push @scenario_files,$_;
}
closedir(DIRHANDLE);

my @story_board_files = ();
my @scenario_jump_routes = ();
my %recursions = {};

for my $scenario_file (@scenario_files){
    # open  file data
    print $scenario_directory.'/'.$scenario_file."\n";
    my $lines;
    open(DATAFILE, "<",$scenario_directory.'/'.$scenario_file) or die("Error $scenario_file $!");
    while(my $line = <DATAFILE>){
	chomp($line);
	$lines .= $line."\n";
    }
    close(DATAFILE);
    $lines = decode("utf8",$lines);
    my @scenario_lines = split(/\r\n|\n/,$lines);
    
    # find charactor
    my @charactors = ();
    for my $scenario_line (@scenario_lines){
	if($scenario_line =~ /^#(.*?)$/){
	    push @charactors,$1;
	}
    }
    @charactors = unique_array(@charactors);

    # background music charactors message
    my $scenario_html = "<html><body>\n";
    $scenario_html .= "<h1>".$scenario_file."</h1>"."\n";
    $scenario_html .= "<table class='table'>";
    $scenario_html .= "<tr><td>bg</td><td>music</td>";

    # scenario parse
    my $now_charactor = "";
    my $now_background = "";
    my $now_bgm = "";
    my $line_cnt = 0;
    my @jump_to = ();
    
    my $charactors_td = "";
    for my $charactor (@charactors){
	$charactors_td .= "<td>".$charactor."</td>";
    }
    $scenario_html .= $charactors_td."</tr>\n";

    for my $scenario_line (@scenario_lines){
	$line_cnt++;

	# background
	if($scenario_line =~ /\[bg.*?storage="(.*?)"/){
	    $now_background = $1;
	}
	
	# music
	elsif($scenario_line =~ /\[playbgm.*?storage="(.*?)"/){
	    $now_bgm = $1;
	}
	
	# charactors
	elsif($scenario_line =~ /#(.*?)$/){
	    $now_charactor = $1;
	}

	# jump
	elsif($scenario_line =~ /\[jump.*?storage="(.*?)"/){
	    my $jump_storage = $1;
	    my $jump_target = "";
	    if($scenario_line =~ /\[jump.*?target="(.*?)"/){
		$jump_target = $1;
	    }
	    push @jump_to,$jump_storage.'___'.$jump_target;
	}
	
	# generate line
	# background music charactors message
	#next if($scenario_line !~ /^#/);

	my $capture_flg = 0;
	if($scenario_line =~ /\[(.*?)\]/){
	    my $tag = $1;
	    if(length($tag) == 1){
		$capture_flg = 1;
	    }
	    else{
		$capture_flg = 0;
	    }
	}
	else{
	    $capture_flg = 1;
	    #print $scenario_line."\n";
	}
	if($capture_flg == 1){
	    $scenario_html .= "<tr>";
	    if($now_background){
		$scenario_html .= "<td><img src=\"".$project_directory.'/data/bgimage/'.$now_background."\" width=\"100\"></td>"; # background
	    }
	    else{
		$scenario_html .= "<td></td>"; # background
	    }
	    $scenario_html .= "<td>".$now_bgm."</td>"; # bgm
	    for my $charactor (@charactors){
		if($charactor eq $now_charactor){
		    $scenario_html .= "<td>".$charactor."</td>";
		}
		else{
		    $scenario_html .= "<td></td>";
		}
	    }
	    $scenario_html .= "<td>「".$scenario_line."」</td>";
	    $scenario_html .= "</tr>\n";
	}
    }
    $scenario_html .= "</table>";
    # jump to
    $scenario_html .= "<h2>jump scenario</h2>\n";
    $scenario_html .= "<ul>\n";
    for my $jump_to (@jump_to){
	$scenario_html .= "<li><a href=\"".$project_directory."/data/scenario/".$jump_to."\">".$jump_to."</a></li>\n";
    }
    $scenario_html .= "</ul>\n";
    $scenario_html .= "<p><a href=\"index.html\">index</a></p>";
    $scenario_html .= "</body></html>";
    
    #p $scenario_html;

    # write html
    my $output_filename = "gen_".$scenario_file.".html";
    open(DATAFILE, ">", $output_directory.'/'.$output_filename) or die("Error $output_filename $!");
    print DATAFILE encode("utf8",$scenario_html);
    close(DATAFILE);
    my %story_board_files = (
	'scenario' => $scenario_file,
	'jumps' => \@jump_to,
	);
    push @story_board_files,\%story_board_files;
    $recursions{$scenario_file} = $max_recursion_deep;
}

# index file
# start scenario files
@story_board_files = sort { $a->{'scenario'} cmp $b->{'scenario'} } @story_board_files;
my $index_html = "<html><body>\n";
$index_html .= 'scenario list';
$index_html .= '<ul>';
for my $story_board_file (@story_board_files){
    $index_html .= '<li><a href="'.'gen_'.$story_board_file->{scenario}.'.html">'.$story_board_file->{scenario}.'</a></li>';
}
$index_html .= '</ul>';
# end scenario files

$index_html .= '</body></html>';
my $output_filename = $output_directory."/index.html";
open(DATAFILE, ">", $output_filename) or die("Error $output_filename $!");
print DATAFILE encode("utf8",$index_html);
close(DATAFILE);


sub unique_array {
    my @array = @_;
    my %hash;
    @hash{@array} = ();
    return keys %hash;
}

sub open_scenario_file_to_strings {
    my $filename = shift;
    my $lines;
    open(DATAFILE, "<",$filename) or die("Error $filename $!");
    while(my $line = <DATAFILE>){
	chomp($line);
	$lines .= $line."\n";
    }
    close(DATAFILE);
    $lines = decode("utf8",$lines);
    my @scenario_lines = split(/\r\n|\n/,$lines);
    return \@scenario_lines;
}

sub check_scenario_in_jumps {
    my $lines = shift;
    my @jump_to = ();
    for my $line (@$lines){
	if($line =~ /\[jump.*?storage="(.*?)"/){
	    push @jump_to,$1;
	}
    }
    return \@jump_to;
}

