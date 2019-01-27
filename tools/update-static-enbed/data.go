package main

import (
	"encoding/json"
	"os"
)

type Data struct {
	AvatarURL   string `json:"avatar_url"`
	URL         string `json:"url"`
	Description string `json:"description"`
}

func WriteData(path string, data map[string]Data) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()

	e := json.NewEncoder(f)
	e.SetIndent("", "  ")
	return e.Encode(data)
}
