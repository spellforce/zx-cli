#encoding: utf-8
# typhoeus
# https://github.com/typhoeus/typhoeus
require 'securerandom'

module HttpClient
  def self.get(url, options={})
    params = options[:params] || {}
    params[:traceUUID] = UUIDTools::UUID.timestamp_create().to_s
    headers = {
      "Accept-Encoding" => "application/json; charset=utf-8",
      "Content-Type" => "application/json; charset=utf-8"
    }.merge(options[:headers] || {})

    request = Typhoeus::Request.new(
      url,
      method: :get,
      params: params,
      headers: headers,
      timeout: 300,
      accept_encoding: "gzip",
      followlocation: true,
      userpwd: options[:userpwd]
    )

    request.on_complete do |response|
      return complete(response, url, params, options)
    end

    request.run
  end

  def self.complete(response, url, params, options)
    options[:email] = options[:email] || ''
    if response.success?
      # http code 200
      begin
        res = JSON.parse(response.body)
      rescue => ex
        EsLog.error(url, {email: options[:email], params: params, message: response.body, uuid: params[:traceUUID]})
        return {
          meta: {
            code: response.code,
            uuid: params[:traceUUID]
          },
          data: response.body
        }
      end
      
      if res["meta"] && res["meta"]["code"]
        if res["meta"]["code"] == 200
          return res.with_indifferent_access
        else
          EsLog.error(url, {email: options[:email], params: params, message: res, uuid: params[:traceUUID]})
          return {
            meta: {
              code: res["meta"]["code"],
              message: res["meta"]["publicMessage"] ||  res["meta"]["message"] || "Internal error, please try it again."
            }
          }
        end
      else
        # success but have no meta code
        EsLog.error(url, {email: options[:email], params: params, message: 'meta code is none', uuid: params[:traceUUID]})
        return {
          meta: {
            code: response.code,
          },
          data: res["data"] || res
        }.with_indifferent_access
      end

    elsif response.timed_out?
      EsLog.error(url, {email: options[:email], params: params, message: "Request timeout, please try it later.", uuid: params[:traceUUID]})
      return {
        meta: {
          code: 'timeout',
          message: 'Request timeout, please try it later.',
          uuid: params[:traceUUID]
        }
      }
    elsif response.code == 0
      # Could not get an http response, something's wrong.
      EsLog.error(url, {email: options[:email], params: params, message: "Server #{URI.parse(url).host} is not online", uuid: params[:traceUUID]})
      return {
        meta: {
          code: '500',
          message: "Server #{URI.parse(url).host} is not online, Please try it later.",
          uuid: params[:traceUUID]
        }
      }
    else
      # Received a non-successful http response.
      EsLog.error(url, {email: options[:email], params: params, message: response.body, uuid: params[:traceUUID]})
      begin
        res = JSON.parse(response.body)
      rescue => ex
        return {
          meta: {
            code: response.code,
            message: response.body,
            uuid: params[:traceUUID]
          }
        }
      end

      if res["meta"] && res["meta"]["code"]
        return {
          meta: {
            code: res["meta"]["code"],
            message: res["meta"]["publicMessage"] ||  res["meta"]["message"] || "Internal error, please try it again.",
            uuid: params[:traceUUID]
          }
        }
      else
        return {
          meta: {
            code: response.code,
            message: "response do not match spec",
            uuid: params[:traceUUID]
          },
          data: res
        }
      end
    end
  end

  def self.post(url, options={})
    # url should not have query parameters
    params = options[:params] || {}
    body = options[:body].as_json || {}
    params[:traceUUID] = UUIDTools::UUID.timestamp_create().to_s
    headers = {
      "Accept-Encoding" => "application/json; charset=utf-8",
      "Content-Type" => "application/json; charset=utf-8"
    }.merge(options[:headers] || {})
    request = Typhoeus::Request.new(
      url,
      method: :post,
      params: params,
      body: ActiveSupport::JSON.encode(body),
      headers: headers,
      timeout: 60,
      accept_encoding: "gzip",
      userpwd: options[:userpwd]
    )

    request.on_complete do |response|
      begin
        mergeParams = params.merge(body)
      rescue
        mergeParams = params.merge({body: body})
      end

      return complete(response, url, mergeParams, options)
    end

    request.run
  end

  def self.put(url, options={})
    # url should not have query parameters
    params = options[:params] || {}
    body = options[:body].as_json || {}
    params[:traceUUID] = SecureRandom.uuid
    request = Typhoeus::Request.new(
        url,
        method: :put,
        params: params,
        body: ActiveSupport::JSON.encode(body),
        headers: {
            "Accept-Encoding" => "application/json; charset=utf-8",
            "Content-Type" => "application/json; charset=utf-8"
        },
        timeout: 60,
        accept_encoding: "gzip",
        userpwd: options[:userpwd]
    )

    request.on_complete do |response|
      begin
        mergeParams = params.merge(body)
      rescue
        mergeParams = params.merge({body: body})
      end

      return complete(response, url, mergeParams, options)
    end

    request.run
  end

  def self.delete(url, options={})
    params = options[:params] || {}
    params[:traceUUID] = SecureRandom.uuid
    request = Typhoeus::Request.new(
        url,
        method: :delete,
        params: params,
        headers: {
            "Accept-Encoding" => "application/json; charset=utf-8",
            "Content-Type" => "application/json; charset=utf-8"
        },
        timeout: 60,
        accept_encoding: "gzip",
        userpwd: options[:userpwd]
    )
    request.on_complete do |response|
      return complete(response, url, params, options)
    end

    request.run
  end
end
