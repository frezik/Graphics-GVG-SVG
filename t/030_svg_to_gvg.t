# Copyright (c) 2016  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use Test::More tests => 3;
use strict;
use warnings;
use Graphics::GVG::SVG;


use constant SVG_FILE => 't_data/many_shapes.svg';

my $SVG_DATA = '';
open( my $in, '<', SVG_FILE ) or die "Can't open " . SVG_FILE . ": $!\n";
while( my $line = <$in> ) {
    $SVG_DATA .= $line;
}
close $in;


my $gvg_to_svg = Graphics::GVG::SVG->new;
my $ast = $gvg_to_svg->make_gvg( $SVG_DATA );

my @commands = @{ $ast->commands };
my @lines = grep { ref($_) eq 'Graphics::GVG::AST::Line' } @commands;
my @circles = grep { ref($_) eq 'Graphics::GVG::AST::Circle' } @commands;
my @polys = grep { ref($_) eq 'Graphics::GVG::AST::Polygon' } @commands;

cmp_ok( scalar @lines, '==', 3, "Lines drawn" );
cmp_ok( scalar @circles, '==', 1, "Circles drawn" );
cmp_ok( scalar @polys, '==', 1, "Polygons drawn" );