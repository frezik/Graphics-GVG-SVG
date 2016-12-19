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
use SVG;


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
    return $svg;
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

=head1 DESCRIPTION

=head1 METHODS

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
