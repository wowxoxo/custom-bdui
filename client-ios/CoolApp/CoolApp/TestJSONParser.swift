import Foundation

func testJSONParsing() {
    let jsonString = """
    {
      "screen": {
        "id": "points_screen",
        "components": [
          {
            "type": "container",
            "properties": {
              "orientation": "vertical",
              "padding": 10
            },
            "children": [
              {
                "type": "text",
                "properties": {
                  "text": "Centers",
                  "font_size": 24,
                  "color": "#000000",
                  "alignment": "center"
                }
              },
              {
                "type": "tap-container",
                "properties": {
                  "orientation": "horizontal",
                  "padding": 10,
                  "margin": {
                    "bottom": 10
                  },
                  "deep_link": "https://example.com/office/1"
                },
                "children": [
                  {
                    "type": "text",
                    "properties": {
                      "text": "Office 1",
                      "font_size": 18,
                      "color": "#000000",
                      "flex": 1
                    }
                  },
                  {
                    "type": "text",
                    "properties": {
                      "text": "1.2 km",
                      "font_size": 14,
                      "color": "#888888"
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let parser = JSONParser()
    do {
        let components = try parser.parse(json: jsonData)
        print("JSON parsed successfully: \(components)")
    } catch {
        print("Failed to parse JSON: \(error)")
    }
}

// Call the function to test JSON parsing
//testJSONParsing()
