=begin
medi-8の広告を導入したときからページネーションが動作しなくなった。
広告のJavaScriptとなにかが競合しているっぽい。
手動でリロードすると表示できるので、will_paginateがつくるリンクに細工をいれる。
通常<a href="/monacoin?page=2">のようにつくられるものを
<a href="/monacoin?page=2" target="_self">となるようにする。
これを作っている箇所は will_paginate 内なので、これを作っている箇所をなんとなくカンで
特定しtarget="_self"を突っ込むようにした。
will_paginateバージョンアップとかしたら問題でるかもしれない。
=end

module Torifuku
end

module Torifuku::WillPaginateExt
  def tag(name, value, attributes = {})
    result = super(name, value, attributes)
    # monacoin main
    m = /\A(<a href="\/monacoin\?page=\d+")(>.+)$/.match(result)
    m = /\A(<a rel="next" href="\/monacoin\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a rel="prev" href="\/monacoin\?page=\d+")(>.+)$/.match(result) unless m
    # koto
    m = /\A(<a href="\/koto\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a rel="next" href="\/koto\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a rel="prev" href="\/koto\?page=\d+")(>.+)$/.match(result) unless m
    # monacoin testnet
    m = /\A(<a href="\/\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a rel="next" href="\/\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a rel="prev" href="\/\?page=\d+")(>.+)$/.match(result) unless m
    m = /\A(<a href="#")(>.+)$/.match(result) unless m
    if m
      result = "#{m[1]} target=\"_self\"#{m[2]}"
    end

    result
  end
end

WillPaginate::ViewHelpers::LinkRenderer.prepend(Torifuku::WillPaginateExt)
