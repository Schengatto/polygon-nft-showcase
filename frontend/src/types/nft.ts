export interface NftAttributes {
    backend: number;
    frontend: number;
    leadership: number;
}

export interface NftItem {
    tokenId: number;
    owner: string;
    seller: string
    price: number;
    sold: boolean;
    tokenURI: string;
    attributes: NftAttributes;
}
