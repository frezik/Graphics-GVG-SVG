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
package Graphics::GVG::SVG;

# ABSTRACT: Convert GVG into SVG
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use Graphics::GVG::AST;
use Graphics::GVG::AST::Line;
use Graphics::GVG::AST::Circle;
use Graphics::GVG::AST::Polygon;
use SVG;
use XML::LibXML;


has [qw{ width height }] => (
    is => 'ro',
    isa => 'Int',
    default => 400,
);

sub make_svg
{
    my ($self, $ast) = @_;
    my $svg = SVG->new(
        width => $self->width,
        height => $self->height,
    );
    my $group = $svg->group(
        id => 'main_group',
    );
    $self->_ast_to_svg( $ast, $group );

    return $svg;
}

sub make_gvg
{
    my ($self, $svg_data) = @_;
    my $xml = XML::LibXML->load_xml( string => $svg_data );
    my $ast = $self->_svg_to_ast( $xml );
    return $ast;
}

sub _svg_to_ast
{
    my ($self, $xml) = @_;
    my $main_group = $xml->getElementById( 'main_group' );
    my $ast = Graphics::GVG::AST->new;

    $self->_svg_to_ast_handle_lines( $xml, $ast );
    $self->_svg_to_ast_handle_circles( $xml, $ast );
    $self->_svg_to_ast_handle_polygons( $xml, $ast );

    return $ast;
}

sub _svg_to_ast_handle_lines
{
    my ($self, $xml, $ast) = @_;
    my @nodes = $xml->getElementsByTagName( 'line' );
    
    foreach my $node (@nodes) {
        my $cmd = Graphics::GVG::AST::Line->new({
            x1 => $node->getAttribute( 'x1' ),
            y1 => $node->getAttribute( 'y1' ),
            x2 => $node->getAttribute( 'x2' ),
            y2 => $node->getAttribute( 'y2' ),
            color => $self->_get_color_for_element( $node ),
        });
        $ast->push_command( $cmd );
    }
    return;
}

sub _svg_to_ast_handle_circles
{
    my ($self, $xml, $ast) = @_;
    my @nodes = $xml->getElementsByTagName( 'circle' );

    foreach my $node (@nodes) {
        my $cmd = Graphics::GVG::AST::Circle->new({
            cx => $node->getAttribute( 'cx' ),
            cy => $node->getAttribute( 'cy' ),
            r => $node->getAttribute( 'r' ),
            color => $self->_get_color_for_element( $node ),
        });
        $ast->push_command( $cmd );
    }
    return;
}

sub _svg_to_ast_handle_polygons
{
    my ($self, $xml, $ast) = @_;
    my @nodes = $xml->getElementsByTagName( 'polygon' );

    foreach my $node (@nodes) {
        # TODO
        my $cmd = Graphics::GVG::AST::Polygon->new({
            cx => 0,
            cy => 0,
            r => 0,
            rotate => 0,
            color => $self->_get_color_for_element( $node ),
        });
        $ast->push_command( $cmd );
    }
    return;
}

sub _get_color_for_element
{
    my ($self, $node) = @_;
    # There are many ways to set the color in SVG, but Inkscape sets it in 
    # using the stroke selector using the CSS style attribute. Since we're 
    # mainly targeting Inkscape, we'll go with that.
    my $style = $node->getAttribute( 'style' );
    my ($hex_color) = $style =~ /stroke: \s+ \#([0-9abcdefABCDEF]+)/x;
    my $color = hex $hex_color;
    $color <<= 8;
    $color |= 0x000000ff;
    return $color;
}

sub _ast_to_svg
{
    my ($self, $ast, $group) = @_;

    foreach my $cmd (@{ $ast->commands }) {
        my $ret = '';
        if(! ref $cmd ) {
            warn "Not a ref, don't know what to do with '$_'\n";
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Line' ) ) {
            $self->_draw_line( $cmd, $group );
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Rect' ) ) {
            $self->_draw_rect( $cmd, $group );
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Polygon' ) ) {
            $self->_draw_poly( $cmd, $group );
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Circle' ) ) {
            $self->_draw_circle( $cmd, $group );
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Ellipse' ) ) {
            $self->_draw_ellipse( $cmd, $group );
        }
        elsif( $cmd->isa( 'Graphics::GVG::AST::Glow' ) ) {
            $self->_ast_to_svg( $cmd, $group );
        }
        else {
            warn "Don't know what to do with " . ref($_) . "\n";
        }
    }

    return;
}

sub _draw_line
{
    my ($self, $cmd, $group) = @_;
    $group->line(
        x1 => $self->_coord_convert_x( $cmd->x1 ),
        y1 => $self->_coord_convert_y( $cmd->y1 ),
        x2 => $self->_coord_convert_x( $cmd->x2 ),
        y2 => $self->_coord_convert_y( $cmd->y2 ),
        style => {
            $self->_default_style,
            stroke => $self->_color_to_style( $cmd->color ),
        },
    );
    return;
}

sub _draw_rect
{
    my ($self, $cmd, $group) = @_;
    $group->rect(
        x => $self->_coord_convert_x( $cmd->x ),
        y => $self->_coord_convert_y( $cmd->y ),
        width => $self->_coord_convert_x( $cmd->x ),
        height => $self->_coord_convert_y( $cmd->y ),
        style => {
            $self->_default_style,
            stroke => $self->_color_to_style( $cmd->color ),
        },
    );
    return;
}

sub _draw_poly
{
    my ($self, $cmd, $group) = @_;
    my (@x_coords, @y_coords);
    foreach my $coords (@{ $cmd->coords }) {
        push @x_coords, $self->_coord_convert_x( $coords->[0] );
        push @y_coords, $self->_coord_convert_y( $coords->[1] );
    }

    my $points = $group->get_path(
        x => \@x_coords,
        y => \@y_coords,
        -type => 'polygon',
    );
    $group->polygon(
        %$points,
        style => {
            $self->_default_style,
            stroke => $self->_color_to_style( $cmd->color ),
        },
    );
    return;
}

sub _draw_circle
{
    my ($self, $cmd, $group) = @_;
    $group->circle(
        cx => $self->_coord_convert_x( $cmd->cx ),
        cy => $self->_coord_convert_y( $cmd->cy ),
        # Arbitrarily say the radius is according to the x coord.
        r => $self->_coord_convert_x( $cmd->r ),
        style => {
            $self->_default_style,
            stroke => $self->_color_to_style( $cmd->color ),
        },
    );
    return;
}

sub _draw_ellipse
{
    my ($self, $cmd, $group) = @_;
    $group->circle(
        cx => $self->_coord_convert_x( $cmd->cx ),
        cy => $self->_coord_convert_y( $cmd->cy ),
        rx => $self->_coord_convert_x( $cmd->rx ),
        ry => $self->_coord_convert_y( $cmd->ry ),
        style => {
            $self->_default_style,
            stroke => $self->_color_to_style( $cmd->color ),
        },
    );
    return;
}

sub _default_style
{
    my ($self) = @_;
    my %style = (
        fill => 'none',
    );
    return %style;
}

sub _color_to_style
{
    my ($self, $color) = @_;
    my $rgb = $color >> 8;
    my $hex = sprintf '%x', $rgb;
    return '#' . $hex;
}

sub _coord_convert_x
{
    my ($self, $coord) = @_;
    return $self->_coord_convert( $coord, $self->width );
}

sub _coord_convert_y
{
    my ($self, $coord) = @_;
    return $self->_coord_convert( $coord, $self->height );
}

sub _coord_convert
{
    my ($self, $coord, $max) = @_;
    my $percent = ($coord + 1) / 2;
    my $final_coord = sprintf '%.0f', $max * $percent;
    return $final_coord;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  Graphics::GVG::SVG - Convert GVG into SVG

=head1 SYNOPSIS

    use Graphics::GVG;
    use Graphics::GVG::SVG;
    
    my $SCRIPT = <<'END';
        %color = #993399ff;
        circle( %color, 0.5, 0.25, 0.3 );

        glow {
            line( %color, 0.25, 0.25, 0.75, 0.75 );
            line( %color, 0.75, 0.75, 0.75, -0.75 );
            line( %color, 0.75, -0.75, 0.25, 0.25 );
        }

        %color = #88aa88ff;
        poly( %color, -0.25, -0.25, 0.6, 6, 0 );
    END
    
    
    my $gvg = Graphics::GVG->new;
    my $ast = $gvg->parse( $SCRIPT );
    
    my $gvg_to_svg = Graphics::GVG::SVG->new;
    my $svg = $gvg_to_svg->make_svg( $ast );

=head1 DESCRIPTION

Takes a L<Graphics::GVG::AST> and converts it into an SVG

=head1 METHODS

=head2 make_svg

  $gvg_to_svg->make_svg( $ast );

Takes a L<Graphics::GVG::AST> object.  Returns the same representation as an 
L<SVG> object.

=head1 SEE ALSO

=over 4

=item * L<Graphics::GVG>

=item * L<SVG>

=back

=head1 LICENSE

    Copyright (c) 2016  Timm Murray
    All rights reserved.

    Redistribution and use in source and binary forms, with or without 
    modification, are permitted provided that the following conditions are met:

        * Redistributions of source code must retain the above copyright notice, 
          this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright 
          notice, this list of conditions and the following disclaimer in the 
          documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.

=cut
