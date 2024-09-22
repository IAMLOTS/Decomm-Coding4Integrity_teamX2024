import FlexSearch from "flexsearch";

const Currency: any = {
  btc: { btc: null },
  eth: { eth: null },
  icp: { icp: null },
  usd: { usd: null },
  eur: { eur: null },
  gbp: { gbp: null },
  kt: { kt: null },
};

export type Post = {
  productLongDesc: string;
  productCategory: string;
  name: string;
  productShortDesc: string;
  productID: number;
  isSold: boolean;
  isVisible: boolean;
  sellerID: string;
  productPrice: productPrice;
  productPicture: string;
};

export type Result = {
  productLongDesc: string[];
  productCategory: string;
  name: string;
  productShortDesc: string;
  productID: number;
  isSold: boolean;
  isVisible: boolean;
  sellerID: string;
  productPrice: productPrice;
  productPicture: string;
};

export type productPrice = {
  currency: typeof Currency;
  amount: number;
};

let postsIndex: FlexSearch.Index;
let posts: Post[];

export function createPostsIndex(data: Post[]) {
  postsIndex = new FlexSearch.Index({ tokenize: "forward" });

  data.forEach((post, i) => {
    const item = `${post.name} ${post.productLongDesc}`;
    postsIndex.add(i, item);
  });

  posts = data;
}

export function searchPostsIndex(searchTerm: string) {
  const match = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const results = postsIndex.search(match);

  return results
    .map((index) => posts[index as number])
    .map(
      ({
        productLongDesc,
        productCategory,
        name,
        productShortDesc,
        productID,
        isSold,
        isVisible,
        sellerID,
        productPrice,
        productPicture,
      }) => {
        return {
          productLongDesc: replaceTextWithMarker(productLongDesc, match),
          productCategory,
          name: replaceTextWithMarker(name, match),
          productShortDesc: replaceTextWithMarker(productShortDesc, match),
          productID,
          isSold,
          isVisible,
          sellerID,
          productPrice,
          productPicture,
        };
      },
    );
}

function replaceTextWithMarker(text: string, match: string) {
  const regex = new RegExp(match, "gi");
  return text.replaceAll(regex, (match) => `<mark>${match}</mark>`);
}
