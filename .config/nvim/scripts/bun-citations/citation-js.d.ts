declare module "citation-js" {
  class Cite {
    constructor(data: unknown);
    static async(input: string): Promise<Cite>;
    format(style: string, options?: Record<string, unknown>): string;
  }
  export default Cite;
}
