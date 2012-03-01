require 'set'

class ExchangeController < ApplicationController

  before_filter :auth

  def index
  end

  def import
    @source = params[:source].to_s
    @file = params[:file].to_s
  end

  def parse_updated_param(value)
    param = value.gsub(/\D/, "")
    range_start = ''
    range_end = ''
    if param != ""
      if param.length == 8
        range_start = "#{param[0, 4]}-#{param[4, 2]}-#{param[6, 2]} 00:00:00"
        range_end = "#{param[0, 4]}-#{param[4, 2]}-#{param[6, 2]} 23:59:59"
      elsif param.length == 16
        range_start = "#{param[0, 4]}-#{param[4, 2]}-#{param[6, 2]} 00:00:00"
        range_end = "#{param[8, 4]}-#{param[12, 2]}-#{param[14, 2]} 23:59:59"
        param = "#{param[0, 8]}-#{param[8, 8]}"
      else
        param = ""
      end
    end
    return param, range_start, range_end
  end

  def export
    uiks_str = params[:uiks].to_s
    if uiks_str != ""
      @uiks = uiks_str.gsub(" ", "").split(',')
      @comms = Commission.where("id IN (?)", @uiks).map { |c| [c, get_ancestors(c.ancestry)] }
      final_uiks = get_commission_uiks(@comms.map {|c, a| c})
    else
      final_uiks = nil
    end

    @updated, range_start, range_end = parse_updated_param(params[:updated].to_s)
    conditions, vals = prepare_query_conditions(final_uiks, nil, range_start, range_end)

    @filter = params[:filter].to_s
    if @filter != ""
      conditions = conditions + " and source like ?"
      vals = vals + [@filter]

      @sources = Protocol.find(:all, :select => "distinct source", :conditions => ([conditions] + vals)).map { |p| p.source }
    end

    @count = Protocol.count_by_sql(["select count(id) from protocols where " + conditions] + vals)
  end

  def get_commission_uiks(commissions)
    ids = Set.new
    commissions.each do |c|
      if c.is_uik
        ids.add(c.id)
      else
        ancestry = c.id.to_s
        if c.ancestry
          ancestry = c.ancestry + '/' + ancestry
        end
        r = Commission.find(:all, :select => "distinct id", :conditions => ["is_uik = 1 and ancestry like ?", "#{ancestry}%"]).map { |p| p.id }
        r.each do |id|
          ids.add(id)
        end
      end
    end
    ids.to_a
  end

  def get_ancestors(ids)
    if ids
      ids.split('/').map { |i| get_commission_by_id(i) }
    else
      []
    end
  end

  def get_commission_by_id(id)
    res = Commission.where("id = ?", id)
    if res
      res[0]
    else
      nil
    end
  end

  def compress(path)
    require 'zip/zip'
    require 'zip/zipfilesystem'

    path.sub!(%r[/$], '')
    archive = File.join(path, File.basename(path))+'.zip'
    FileUtils.rm archive, :force=>true

    Zip::ZipFile.open(archive, 'w') do |zipfile|
      Dir["#{path}/**/**"].reject { |f| f==archive }.each do |file|
        zipfile.add(file.sub(path+'/', ''), file)
      end
    end
  end

  def unique_temp_folder
    base = './public/uploads/tmp/' + Time.now().strftime("%Y%m%d.%H%M%S")
    path = base
    while File.exists? path do
      path = base + '.' + rand(999999).to_s
    end
    FileUtils.mkpath path
    path
  end

  def delete_older(dir, time)
    save = Dir.getwd
    Dir.chdir(dir)
    Dir.foreach(".") do |entry|
      # We're not handling directories here
      next if File.stat(entry).directory?
      # Use the modification time
      if File.mtime(entry) < time
        File.unlink(entry)
      end
    end
    Dir.chdir(save)
  end

  def unique_export_zip
    export_path = './public/uploads/export/'
    if not File.exists? export_path
      FileUtils.mkpath export_path
    end
    delete_older(export_path, Time.now - 1.day)
    base = export_path + Time.now().strftime("%Y%m%d.%H%M%S")
    path = base + '.zip'
    while File.exists? path do
      path = base + '.' + rand(999999).to_s + '.zip'
    end
    path
  end

  def prepare_query_conditions(uiks, sources, range_start, range_end)
    # `priority` = 0 and `source` in ('test', 'test1') and `commission_id` in (5814, 5815) and `updated_at` >= '2012-02-19 00:00:00' and `updated_at` <= '2012-02-19 23:59:59'
    conditions = "priority < 100"
    vals = []
    if uiks
      conditions += " and commission_id in (?)"
      vals += [uiks]
    end
    if sources
      conditions += " and source in (?)"
      vals += [sources]
    end
    if range_start != "" && range_end != ""
      conditions += " and updated_at >= ? and updated_at <= ?"
      vals += [range_start, range_end]
    end
    return conditions, vals
  end

  def prepare_data_file file
    if not File.exists? file
      File.open(file, 'w:UTF-8') do |f|
        f << "id\tuik\tv1\tv2\tv3\tv4\tv5\tv6\tv7\tv8\tv9\tv10\tv11\tv12\tv13\tv14\tv15\tv16\tv17\tv18\tv19\tv20\tv21\tv22\tv23\tv24\tv25\tv26\tv27\tv28\tv29\tv30\tsource\tpriority\n"
      end
    end
  end

  def append_protocol_data file, protocol, uik
    File.open(file, 'a:UTF-8') do |f|
      f << "#{protocol.id}\t\"#{uik.name}\"\t#{protocol.v1}\t#{protocol.v2}\t#{protocol.v3}\t#{protocol.v4}\t#{protocol.v5}\t#{protocol.v6}\t#{protocol.v7}\t#{protocol.v8}\t#{protocol.v9}\t#{protocol.v10}\t#{protocol.v11}\t#{protocol.v12}\t#{protocol.v13}\t#{protocol.v14}\t#{protocol.v15}\t#{protocol.v16}\t#{protocol.v17}\t#{protocol.v18}\t#{protocol.v19}\t#{protocol.v20}\t#{protocol.v21}\t#{protocol.v22}\t#{protocol.v23}\t#{protocol.v24}\t#{protocol.v25}\t#{protocol.v26}\t#{protocol.v27}\t#{protocol.v28}\t#{protocol.v29}\t#{protocol.v30}\t\"#{protocol.source}\"\t#{protocol.priority}\n"
    end
  end

  def commission_path(uik)
    ancestors = get_ancestors(uik.ancestry)
    if ancestors
      '/' + ancestors.map { |a| a.name }.join('/')
    else
      ''
    end
  end

  def src_picture_file(file_name)
    "./public#{file_name}"
  end

  def dst_picture_file(path, protocol_id, index, ext)
    "#{path}/#{protocol_id}.#{index+1}#{ext}"
  end

  def zip_file_path(path)
    "#{path}/#{File.basename(path)}.zip"
  end

  def export_confirmed
    path = unique_temp_folder

    if params[:uiks]
      commissions = Commission.where("id IN (?)", params[:uiks])
      uiks = get_commission_uiks(commissions)
    else
      uiks = nil
    end

    updated, range_start, range_end = parse_updated_param(params[:updated].to_s)

    conditions, vals = prepare_query_conditions uiks, params[:sources], range_start, range_end
    where = [conditions] + vals

    protocols = Protocol.where where
    if protocols
      protocols.each do |p|
        pictures = p.pictures
        if pictures and pictures.length > 0
          uik = get_commission_by_id(p.commission_id)
          protocol_path = path + commission_path(uik)
          data_file = protocol_path + '/data.csv'
          FileUtils.mkpath protocol_path
          prepare_data_file data_file
          append_protocol_data data_file, p, uik
          pictures.each_with_index do |pic, index|
            FileUtils.copy src_picture_file(pic.image.to_s), dst_picture_file(protocol_path, p.id, index, File.extname(pic.image.to_s))
          end
        end
      end
    end

    compress path

    if File.exists? zip_file_path(path)
      res = unique_export_zip
      FileUtils.move zip_file_path(path), res
      FileUtils.rmtree path
      redirect_to "/uploads/export/" + File.basename(res)
    else
      FileUtils.rmtree path
    end

  end

end
