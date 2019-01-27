package main

import (
	"reflect"
	"testing"
)

func TestParseShortcode(t *testing.T) {
	cases := []struct {
		src      string
		expected *Shortcode
	}{
		{
			`{{<hr>}}`,
			&Shortcode{
				Tag:   "hr",
				Attrs: map[string]string{},
			},
		}, {
			`{{<github src="ueokande/hoge">}}`,
			&Shortcode{
				Tag:   "github",
				Attrs: map[string]string{"src": "ueokande/hoge"},
			},
		}, {
			`{{<figure src="image.png" alt="the figure">}}`,
			&Shortcode{
				Tag:   "figure",
				Attrs: map[string]string{"src": "image.png", "alt": "the figure"},
			},
		},
	}
	for _, c := range cases {
		res, err := ParseShortcode(c.src)
		if err != nil {
			t.Error(err)
		}
		if !reflect.DeepEqual(res, c.expected) {
			t.Error("unexpected result:", res)
		}
	}
}
