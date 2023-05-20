local utils = require("fox.utils")

describe("extract_project_path", function()
  it("reads ssh correctly", function()
    local result = utils.extract_project_path("git@github.com:tobb10001/fox.nvim.git")
    assert.are.equal("tobb10001/fox.nvim", result)
  end)
  it("reads https correctly", function()
    local result = utils.extract_project_path("https://github.com/tobb10001/fox.nvim.git")
    assert.are.equal("tobb10001/fox.nvim", result)
  end)
end)
