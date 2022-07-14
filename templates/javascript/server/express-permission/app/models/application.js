
const { Model } = require("sequelize");

class ApplicationRecord extends Model {
  static _model = null;

  constructor(...args) {
    super(...args);
  }

  static search(params) {
    return {}
  }

  static async pageTable(params) {
    let { pagination, sortDirection, sortField } = params;

    const { current, pageSize } = pagination;
    const limit = parseInt(pageSize, 10);
    const offset = (current - 1) * limit;
    const order = sortField ? [sortField, sortDirection] : ["id", "DESC"];

    const condtions = {
      order: [order],
      offset,
      limit,
      where: this.search(params)
    };
    
    const data = await this._model.findAndCountAll(condtions);

    const results = data.rows;

    return {
      total: data.count,
      results
    };
  }
  
}

module.exports = ApplicationRecord;