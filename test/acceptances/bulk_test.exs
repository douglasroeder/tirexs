defmodule Acceptances.BulkTest do
  use ExUnit.Case

  use Tirexs.Mapping
  import Tirexs.Bulk
  alias Tirexs.HTTP

  test "bulk index documents" do
    documents = [
      [ id: 1, title: "My first blog post"],
      [ id: 2, title: "My second blog post"]
    ]

    payload = bulk do
      index([index: "website", type: "blog"], documents)
    end

    {:ok, 200, response} = Tirexs.bump!(payload)._bulk()

    refute response.errors
  end

  test "bulk index documents with custom mapping" do
    HTTP.delete("articles")

    index = [index: "articles", type: "article"]

    mappings dynamic: "false", _parent: [type: "blog"] do
      indexes "id", type: "integer"
      indexes "title", type: "string"
    end

    {:ok, 200, _response} = Tirexs.Mapping.create_resource(index)
    HTTP.get("/_cluster/health?wait_for_status=yellow&timeout=50s")

    documents = [
      [ id: 1, title: "My first blog post", _parent: 1],
      [ id: 2, title: "My second blog post", _parent: 1]
    ]

    payload = bulk do
      index([index: "articles", type: "article"], documents)
    end

    {:ok, 200, response} = Tirexs.bump!(payload)._bulk()

    refute response.errors
  end
end
