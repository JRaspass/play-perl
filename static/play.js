import { EditorView, basicSetup } from 'codemirror';
import { StreamLanguage }         from '@codemirror/language';
import { perl }                   from '@codemirror/legacy-modes/mode/perl';

const fib = `
use v5.36;

sub fib($n) {
    return $n if $n < 2;
    return fib($n - 1) + fib($n - 2);
}

say fib(10);
`.trim();

new EditorView({
    doc:        fib,
    extensions: [ basicSetup, StreamLanguage.define(perl) ],
    parent:     document.querySelector('main'),
});
