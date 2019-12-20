package models

type FooterConfigItem struct {
	Display bool
	Text    string
	Link    string
}

type FooterConfig struct {
	Docs      FooterConfigItem
	Support   FooterConfigItem
	Community FooterConfigItem
}

type CustomFooterQuery struct {
	Result FooterConfig
}
